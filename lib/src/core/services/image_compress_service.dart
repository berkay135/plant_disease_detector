import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Service for compressing images before upload
class ImageCompressService {
  /// Compress image file for upload
  /// 
  /// - Avatar images: 256x256, quality 80
  /// - Plant images: 800x800, quality 85
  static Future<File?> compressForUpload({
    required File file,
    bool isAvatar = false,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      
      // Define compression parameters based on image type
      final int targetWidth = isAvatar ? 256 : 800;
      final int targetHeight = isAvatar ? 256 : 800;
      final int quality = isAvatar ? 80 : 85;
      
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      
      if (compressedBytes == null) {
        print('⚠️ Image compression failed, using original');
        return file;
      }
      
      // Save compressed file to temp directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedFile = File('${tempDir.path}/compressed_$timestamp.jpg');
      await compressedFile.writeAsBytes(compressedBytes);
      
      // Log compression stats
      final originalSize = bytes.length / 1024;
      final compressedSize = compressedBytes.length / 1024;
      final savings = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);
      print('✅ Image compressed: ${originalSize.toStringAsFixed(1)}KB → ${compressedSize.toStringAsFixed(1)}KB ($savings% smaller)');
      
      return compressedFile;
    } catch (e) {
      print('❌ Image compression error: $e');
      return file; // Return original file if compression fails
    }
  }
  
  /// Compress image from path
  static Future<File?> compressFromPath({
    required String path,
    bool isAvatar = false,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      print('⚠️ File not found: $path');
      return null;
    }
    return compressForUpload(file: file, isAvatar: isAvatar);
  }
  
  /// Compress bytes directly
  static Future<Uint8List?> compressBytes({
    required Uint8List bytes,
    bool isAvatar = false,
  }) async {
    try {
      final int targetWidth = isAvatar ? 256 : 800;
      final int targetHeight = isAvatar ? 256 : 800;
      final int quality = isAvatar ? 80 : 85;
      
      return await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      print('❌ Bytes compression error: $e');
      return null;
    }
  }
}
