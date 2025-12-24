import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_disease_detector/src/core/services/image_cache_service.dart';

/// A widget that displays an image from either local path or network URL with caching
class CachedImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget? placeholder;

  const CachedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.placeholder,
  });

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  String? _localPath;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final localPath = await ImageCacheService().getLocalPath(widget.imagePath);
      
      if (mounted) {
        setState(() {
          _localPath = localPath;
          _isLoading = false;
          _hasError = localPath == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? 
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
    }

    if (_hasError || _localPath == null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, Exception('Image not found'), null);
      }
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[600],
        ),
      );
    }

    return Image.file(
      File(_localPath!),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: widget.errorBuilder ?? (context, error, stackTrace) {
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[300],
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[600],
          ),
        );
      },
    );
  }
}
