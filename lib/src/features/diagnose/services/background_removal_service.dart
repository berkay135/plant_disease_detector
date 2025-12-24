import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Result of background removal operation
class BackgroundRemovalResult {
  final File processedImage;
  final double foregroundRatio; // 0.0 - 1.0
  final bool usedOriginal; // true if original was used due to high foreground ratio
  
  BackgroundRemovalResult({
    required this.processedImage,
    required this.foregroundRatio,
    this.usedOriginal = false,
  });
}

class BackgroundRemovalService {
  Interpreter? _interpreter;
  bool _isInitialized = false;
  int _outputCount = 0;
  
  /// Minimum foreground ratio before falling back to original image
  /// If less than 40% is detected as foreground (i.e., more than 60% removed as background),
  /// the model likely removed too much and we should use the original image
  static const double minForegroundRatio = 0.40;

  /// Initialize the U2-Net model for background removal
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔄 Loading U2-Net model...');
      
      // Load model from assets as bytes first
      final modelBytes = await rootBundle.load('assets/models/u2netp_float16.tflite');
      final modelBuffer = modelBytes.buffer.asUint8List();
      print('   Model loaded: ${modelBuffer.length} bytes');
      
      // Create interpreter options
      final options = InterpreterOptions()..threads = 4;
      
      // Create interpreter from buffer
      _interpreter = Interpreter.fromBuffer(modelBuffer, options: options);
      
      // Allocate tensors
      _interpreter!.allocateTensors();
      
      _isInitialized = true;
      print('✅ U2-Net model initialized successfully');
      
      // Print model info - check ALL inputs and outputs
      print('   📥 Input count: ${_interpreter!.getInputTensors().length}');
      _outputCount = _interpreter!.getOutputTensors().length;
      print('   📤 Output count: $_outputCount');
      
      final inputTensor = _interpreter!.getInputTensor(0);
      print('   📥 Input[0] shape: ${inputTensor.shape}');
      print('   📥 Input[0] type: ${inputTensor.type}');
      
      // Print all output shapes (U2-Net has 7 outputs: d1-d7)
      for (int i = 0; i < _outputCount; i++) {
        final outTensor = _interpreter!.getOutputTensor(i);
        print('   📤 Output[$i] shape: ${outTensor.shape}, type: ${outTensor.type}');
      }
      
    } catch (e, stackTrace) {
      print('❌ Failed to load U2-Net model: $e');
      print('   Stack: $stackTrace');
    }
    
    if (_interpreter == null) {
      print('⚠️ U2-Net model not loaded. Background removal will fail.');
    }
  }

  /// Remove background from an image file
  /// Returns a BackgroundRemovalResult with the processed image and foreground ratio
  Future<BackgroundRemovalResult> removeBackground(File imageFile) async {
    await initialize();

    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    if (_interpreter == null) {
      throw Exception('❌ U2-Net model not loaded! Cannot process image.');
    }

    // U2-Net model ile background removal
    final (processedImage, foregroundRatio) = await _removeBackgroundWithU2Net(originalImage);
    
    // Check if foreground ratio is too low (too much background removed = likely failed segmentation)
    if (foregroundRatio < minForegroundRatio) {
      print('⚠️ Foreground ratio too low (${(foregroundRatio * 100).toStringAsFixed(1)}% < ${(minForegroundRatio * 100).toStringAsFixed(0)}%)');
      print('   📸 Too much background removed - using original image instead');
      
      // Return original image with a flag indicating fallback
      return BackgroundRemovalResult(
        processedImage: imageFile,
        foregroundRatio: foregroundRatio,
        usedOriginal: true,
      );
    }

    // Save processed image to app directory
    final processedBytes = img.encodePng(processedImage);
    
    // Try multiple storage locations for better accessibility
    Directory? testFolder;
    String testImagesPath = '';
    
    try {
      // Try external storage first (easier to access)
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        testImagesPath = '${directory.path}/test_images';
        testFolder = Directory(testImagesPath);
        if (!await testFolder.exists()) {
          await testFolder.create(recursive: true);
        }
      }
    } catch (e) {
      print('⚠️ External storage kullanılamadı: $e');
    }
    
    // If external storage failed, use app directory
    if (testFolder == null || !await testFolder.exists()) {
      final appDir = await getApplicationDocumentsDirectory();
      testImagesPath = '${appDir.path}/test_images';
      testFolder = Directory(testImagesPath);
      if (!await testFolder.exists()) {
        await testFolder.create(recursive: true);
      }
    }
    
    // Save both original and processed for comparison
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Save processed image
    final processedFile = File('$testImagesPath/processed_$timestamp.png');
    await processedFile.writeAsBytes(processedBytes);
    
    // Copy original for comparison
    final originalCopy = File('$testImagesPath/original_$timestamp.jpg');
    await imageFile.copy(originalCopy.path);
    
    print('✅ Test görüntüleri kaydedildi:');
    print('   📸 Original: ${originalCopy.path}');
    print('   🎨 Processed: ${processedFile.path}');
    print('   📁 Klasör: $testImagesPath');
    print('');
    print('📲 Dosyalara erişmek için:');
    print('   adb shell ls $testImagesPath');
    print('   adb pull $testImagesPath ./test_images/');

    return BackgroundRemovalResult(
      processedImage: processedFile,
      foregroundRatio: foregroundRatio,
      usedOriginal: false,
    );
  }

  /// U2-Net model ile background removal (TFLite)
  /// Python scriptindeki preprocessing/postprocessing adımlarının birebir uygulaması
  /// Returns (processedImage, foregroundRatio)
  Future<(img.Image, double)> _removeBackgroundWithU2Net(img.Image image) async {
    print('🔄 Starting U2-Net background removal...');
    print('   Original size: ${image.width}x${image.height}');
    
    try {
      // Step 1: Resize image to model input size (320x320 for U2-Net)
      final resized = img.copyResize(image, width: 320, height: 320);
      print('   Resized to: 320x320');

      // Step 2: Prepare input tensor with ImageNet normalization
      // Input shape: [1, 320, 320, 3] - use num type as in official examples
      final imageMatrix = List.generate(
        320,
        (y) => List.generate(
          320,
          (x) {
            final pixel = resized.getPixel(x, y);
            // ImageNet normalization
            const meanR = 0.485, meanG = 0.456, meanB = 0.406;
            const stdR = 0.229, stdG = 0.224, stdB = 0.225;
            final r = (pixel.r.toInt() / 255.0 - meanR) / stdR;
            final g = (pixel.g.toInt() / 255.0 - meanG) / stdG;
            final b = (pixel.b.toInt() / 255.0 - meanB) / stdB;
            return [r, g, b];
          },
        ),
      );
      // Input as list for runForMultipleInputs
      final inputs = [[imageMatrix]];
      print('   Input tensor prepared');

      // U2-Net has multiple outputs (d1, d2, d3, d4, d5, d6, d7)
      // We need to create a buffer for EACH output, but only use d1 (index 0)
      print('   Preparing $_outputCount output buffers...');
      final outputs = <int, Object>{};
      for (int i = 0; i < _outputCount; i++) {
        final shape = _interpreter!.getOutputTensor(i).shape;
        // Create output buffer matching each tensor's shape
        outputs[i] = List.filled(shape[0] * shape[1] * shape[2] * shape[3], 0.0)
            .reshape([shape[0], shape[1], shape[2], shape[3]]);
      }
      print('   Output buffers prepared for $_outputCount outputs');

      // Run inference with runForMultipleInputs (required for multi-output models)
      print('   Running model inference with runForMultipleInputs...');
      _interpreter!.runForMultipleInputs(inputs, outputs);
      print('   ✅ Model inference completed');
      
      // Get the first output (d1 - main mask)
      final output = outputs[0] as List<dynamic>;
      
      // Debug: check output values at center
      print('   Sample output value at center: ${output[0][160][160][0]}');

      // Step 3: Apply sigmoid and create mask
      print('   Creating mask with sigmoid...');
      final mask = _outputToMask(output[0], 320, 320);
      print('   ✅ Mask created');

      // Step 4: Apply mask to original image
      print('   Applying mask to original image...');
      final (result, foregroundRatio) = _applyMaskWithResize(image, mask);
      print('   ✅ Background removal completed');
      return (result, foregroundRatio);
      
    } catch (e, stackTrace) {
      print('❌ ERROR in _removeBackgroundWithU2Net: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Convert output tensor to mask
  /// Note: TFLite model output is already in [0, 1] range (sigmoid already applied internally)
  List<List<double>> _outputToMask(List<dynamic> output, int width, int height) {
    final mask = List.generate(height, (_) => List<double>.filled(width, 0.0));

    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final value = (output[y][x][0] as num).toDouble();
        
        if (value < minVal) minVal = value;
        if (value > maxVal) maxVal = value;
        
        // No sigmoid needed - output is already 0-1 probability
        mask[y][x] = value;
      }
    }
    
    print('   📊 Output range: [$minVal, $maxVal]');

    return mask;
  }

  /// Apply mask to original image with proper resizing
  /// Uses bilinear-like interpolation for smoother edges
  /// Returns (resultImage, foregroundRatio)
  (img.Image, double) _applyMaskWithResize(img.Image original, List<List<double>> mask) {
    final maskHeight = mask.length;
    final maskWidth = mask[0].length;
    
    // Create result with black background
    final result = img.Image(width: original.width, height: original.height);

    // Threshold for binary mask (can adjust 0.5 if needed)
    const threshold = 0.5;
    
    int foregroundPixels = 0;
    int totalPixels = original.width * original.height;
    
    for (int y = 0; y < original.height; y++) {
      for (int x = 0; x < original.width; x++) {
        // Map coordinates to mask with bilinear-like sampling
        final maskYf = y * (maskHeight - 1) / (original.height - 1);
        final maskXf = x * (maskWidth - 1) / (original.width - 1);
        
        final maskY0 = maskYf.floor().clamp(0, maskHeight - 1);
        final maskX0 = maskXf.floor().clamp(0, maskWidth - 1);
        final maskY1 = (maskY0 + 1).clamp(0, maskHeight - 1);
        final maskX1 = (maskX0 + 1).clamp(0, maskWidth - 1);
        
        final fy = maskYf - maskY0;
        final fx = maskXf - maskX0;
        
        // Bilinear interpolation
        final v00 = mask[maskY0][maskX0];
        final v01 = mask[maskY0][maskX1];
        final v10 = mask[maskY1][maskX0];
        final v11 = mask[maskY1][maskX1];
        
        final maskValue = v00 * (1 - fx) * (1 - fy) +
                          v01 * fx * (1 - fy) +
                          v10 * (1 - fx) * fy +
                          v11 * fx * fy;
        
        if (maskValue > threshold) {
          // Foreground - keep original pixel
          final pixel = original.getPixel(x, y);
          result.setPixelRgba(
            x, 
            y, 
            pixel.r.toInt(), 
            pixel.g.toInt(), 
            pixel.b.toInt(), 
            255,
          );
          foregroundPixels++;
        } else {
          // Background - black pixel
          result.setPixelRgba(x, y, 0, 0, 0, 255);
        }
      }
    }
    
    final foregroundRatio = foregroundPixels / totalPixels;
    final percentage = (foregroundRatio * 100).toStringAsFixed(1);
    print('   🌿 Foreground: $foregroundPixels / $totalPixels ($percentage%)');

    return (result, foregroundRatio);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
