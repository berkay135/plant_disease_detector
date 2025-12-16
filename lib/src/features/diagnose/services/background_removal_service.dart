import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';

class BackgroundRemovalService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  /// Initialize the U2-Net model for background removal
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Loading U2-Net model for background removal...');
      _interpreter = await Interpreter.fromAsset('models/u2netp_float16.tflite');
      _isInitialized = true;
      print('U2-Net model loaded successfully!');
    } catch (e) {
      print('Warning: U2-Net model not found. Using fallback method.');
      print('Error: $e');
      // Model yoksa fallback yöntemi kullanılacak
    }
  }

  /// Remove background from an image file
  Future<File> removeBackground(File imageFile) async {
    await initialize();

    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    img.Image processedImage;

    if (_interpreter != null) {
      // U2-Net model ile background removal
      processedImage = await _removeBackgroundWithU2Net(originalImage);
    } else {
      // Fallback: Simple color-based segmentation
      processedImage = _removeBackgroundSimple(originalImage);
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

    return processedFile;
  }

  /// U2-Net model ile background removal (TFLite)
  Future<img.Image> _removeBackgroundWithU2Net(img.Image image) async {
    // Resize image to model input size (320x320 for U2-Net)
    final resized = img.copyResize(image, width: 320, height: 320);

    // Prepare input tensor
    final input = _imageToByteListFloat32(resized, 320, 320);

    // Prepare output tensor
    final output = List.filled(1 * 320 * 320 * 1, 0.0).reshape([1, 320, 320, 1]);

    // Run inference
    _interpreter!.run(input, output);

    // Create mask from output
    final mask = _outputToMask(output[0], 320, 320);

    // Apply mask to original image
    return _applyMask(image, mask);
  }

  /// Simple color-based background removal (fallback) - BLACK background
  img.Image _removeBackgroundSimple(img.Image image) {
    print('Using simple background removal (fallback method)');
    
    // Create result with black background
    final result = img.Image(width: image.width, height: image.height);

    // Simple green screen removal or edge detection
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Check if pixel is likely background (white/gray)
        final isBackground = _isBackgroundColor(r, g, b);

        if (isBackground) {
          // Make it BLACK (PlantVillage style)
          result.setPixelRgba(x, y, 0, 0, 0, 255);
        } else {
          // Keep original color
          result.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }

    return result;
  }

  /// Check if color is likely background
  bool _isBackgroundColor(int r, int g, int b) {
    // Check for white/light gray backgrounds
    final isWhite = r > 200 && g > 200 && b > 200;
    
    // Check for uniform colors (common in lab photos)
    final diff1 = (r - g).abs();
    final diff2 = (r - b).abs();
    final diff3 = (g - b).abs();
    final maxDiff = math.max(diff1, math.max(diff2, diff3));
    final isUniform = maxDiff < 30 && (r + g + b) / 3 > 180;

    return isWhite || isUniform;
  }

  /// Convert image to Float32 input tensor
  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image, int inputWidth, int inputHeight) {
    final result = List.generate(
      1,
      (_) => List.generate(
        inputHeight,
        (y) => List.generate(
          inputWidth,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              (pixel.r.toInt() - 127.5) / 127.5,
              (pixel.g.toInt() - 127.5) / 127.5,
              (pixel.b.toInt() - 127.5) / 127.5,
            ];
          },
        ),
      ),
    );

    return result;
  }

  /// Convert model output to binary mask
  List<List<double>> _outputToMask(List output, int width, int height) {
    final mask = List.generate(height, (_) => List<double>.filled(width, 0.0));

    // Find min and max for normalization
    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final val = output[y][x][0] as double;
        if (val < minVal) minVal = val;
        if (val > maxVal) maxVal = val;
      }
    }
    
    final range = maxVal - minVal;
    print('🎭 Mask range: min=$minVal, max=$maxVal');

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Normalize and threshold
        final normalized = range > 0 ? (output[y][x][0] - minVal) / range : 0.5;
        // Values > 0.5 are foreground (leaf)
        mask[y][x] = normalized > 0.5 ? 1.0 : 0.0;
      }
    }

    return mask;
  }

  /// Apply mask to original image with BLACK background (PlantVillage style)
  img.Image _applyMask(img.Image original, List<List<double>> mask) {
    final maskHeight = mask.length;
    final maskWidth = mask[0].length;

    // Create result with black background
    final result = img.Image(width: original.width, height: original.height);
    
    // Fill with black first
    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        result.setPixelRgba(x, y, 0, 0, 0, 255);
      }
    }

    int foregroundPixels = 0;
    for (int y = 0; y < original.height; y++) {
      for (int x = 0; x < original.width; x++) {
        // Map coordinates to mask
        final maskY = (y * maskHeight / original.height).floor().clamp(0, maskHeight - 1);
        final maskX = (x * maskWidth / original.width).floor().clamp(0, maskWidth - 1);

        final maskValue = mask[maskY][maskX];
        
        if (maskValue > 0.5) {
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
        }
        // Background pixels stay black
      }
    }
    
    print('🌿 Foreground pixels: $foregroundPixels / ${original.width * original.height}');

    return result;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
