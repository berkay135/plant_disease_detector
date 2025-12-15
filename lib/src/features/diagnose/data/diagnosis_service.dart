import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class DiagnosisService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/plant_model.tflite');
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
    } catch (e) {
      print('Failed to load model or labels: $e');
    }
  }

  Future<Map<String, dynamic>> diagnose(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      await initialize();
    }

    if (_interpreter == null) {
      throw Exception('Model not initialized');
    }

    // Load and resize image
    final imageData = File(imagePath).readAsBytesSync();
    final image = img.decodeImage(imageData);
    if (image == null) throw Exception('Failed to decode image');

    // Assuming model input size is 224x224. Adjust if your model is different.
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // Convert to input tensor
    // This depends on your model's expected input format (float32 vs uint8, normalization, etc.)
    // Assuming Float32 [1, 224, 224, 3] and normalization to [0, 1]
    final input = _imageToByteListFloat32(resizedImage, 224, 127.5, 127.5);
    
    // Output tensor
    // Assuming output is [1, num_classes]
    final output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

    _interpreter!.run(input, output);

    // Find max probability
    final probabilities = output[0] as List<double>;
    var maxScore = 0.0;
    var maxIndex = 0;

    for (var i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxScore) {
        maxScore = probabilities[i];
        maxIndex = i;
      }
    }

    return {
      'label': _labels![maxIndex],
      'confidence': maxScore,
      'imagePath': imagePath,
    };
  }

  List<List<List<List<double>>>> _imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = List.generate(
        1,
        (i) => List.generate(
            inputSize,
            (j) => List.generate(inputSize, (k) => List.filled(3, 0.0))));
    
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        final pixel = image.getPixel(j, i);
        convertedBytes[0][i][j][0] = (pixel.r - mean) / std;
        convertedBytes[0][i][j][1] = (pixel.g - mean) / std;
        convertedBytes[0][i][j][2] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes;
  }
  
  void dispose() {
    _interpreter?.close();
  }
}
