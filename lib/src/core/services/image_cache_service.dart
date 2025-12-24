import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for caching images from network URLs
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  String? _cacheDir;

  /// Initialize the cache directory
  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _cacheDir = '${dir.path}/image_cache';
    
    // Create cache directory if it doesn't exist
    final cacheDir = Directory(_cacheDir!);
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    print('✅ ImageCacheService initialized: $_cacheDir');
  }

  /// Get cache file path for a URL
  String _getCacheFilePath(String url) {
    final hash = md5.convert(utf8.encode(url)).toString();
    final extension = _getExtension(url);
    return '$_cacheDir/$hash$extension';
  }

  String _getExtension(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '.jpg';
    
    final path = uri.path.toLowerCase();
    if (path.contains('.png')) return '.png';
    if (path.contains('.webp')) return '.webp';
    if (path.contains('.gif')) return '.gif';
    return '.jpg';
  }

  /// Check if image is cached
  Future<bool> isCached(String url) async {
    if (_cacheDir == null) await initialize();
    final file = File(_getCacheFilePath(url));
    return file.exists();
  }

  /// Get cached image file, download if not cached
  Future<File?> getCachedImage(String url) async {
    if (_cacheDir == null) await initialize();
    
    final cachePath = _getCacheFilePath(url);
    final cacheFile = File(cachePath);

    // Return cached file if exists
    if (await cacheFile.exists()) {
      print('✅ ImageCacheService: Found in cache: $cachePath');
      return cacheFile;
    }

    // Download and cache
    try {
      // Clean URL - remove any whitespace/newlines
      final cleanUrl = url.trim();
      final uri = Uri.parse(cleanUrl);
      
      print('📥 ImageCacheService: Downloading from: $cleanUrl');
      print('📥 ImageCacheService: URI scheme: ${uri.scheme}, host: ${uri.host}');
      print('📥 ImageCacheService: URI path: ${uri.path}');
      
      final response = await http.get(uri);
      print('📥 ImageCacheService: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        await cacheFile.writeAsBytes(response.bodyBytes);
        print('✅ ImageCacheService: Cached at: $cachePath');
        return cacheFile;
      } else {
        print('⚠️ ImageCacheService: HTTP error ${response.statusCode}');
        print('⚠️ ImageCacheService: Response body: ${response.body}');
      }
    } catch (e, stack) {
      print('⚠️ ImageCacheService: Download failed: $e');
      print('⚠️ ImageCacheService: Stack: $stack');
    }

    return null;
  }

  /// Get local path for an image (either local file or cached URL)
  Future<String?> getLocalPath(String imagePath) async {
    if (imagePath.isEmpty) {
      print('⚠️ ImageCacheService: Empty image path');
      return null;
    }
    
    // If it's already a local file path (not URL), check if exists
    if (!imagePath.startsWith('http')) {
      final file = File(imagePath);
      if (await file.exists()) {
        return imagePath;
      }
      print('⚠️ ImageCacheService: Local file not found: $imagePath');
      return null;
    }

    // It's a URL, get cached version
    print('🔄 ImageCacheService: Caching URL: $imagePath');
    final cachedFile = await getCachedImage(imagePath);
    if (cachedFile != null) {
      print('✅ ImageCacheService: Cached at: ${cachedFile.path}');
      return cachedFile.path;
    }
    print('⚠️ ImageCacheService: Failed to cache URL');
    return null;
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    if (_cacheDir == null) return;
    
    final cacheDir = Directory(_cacheDir!);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create(recursive: true);
    }
    print('✅ Image cache cleared');
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    if (_cacheDir == null) return 0;
    
    final cacheDir = Directory(_cacheDir!);
    if (!await cacheDir.exists()) return 0;
    
    int size = 0;
    await for (final entity in cacheDir.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }
}
