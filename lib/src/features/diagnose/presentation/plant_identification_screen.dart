import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_disease_detector/src/core/theme/app_theme.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/diagnosis_service.dart';
import 'package:plant_disease_detector/src/features/diagnose/services/background_removal_service.dart';
import 'package:plant_disease_detector/src/features/diagnose/presentation/processing_loading_screen.dart';

class PlantIdentificationScreen extends StatefulWidget {
  const PlantIdentificationScreen({super.key});

  @override
  State<PlantIdentificationScreen> createState() => _PlantIdentificationScreenState();
}

class _PlantIdentificationScreenState extends State<PlantIdentificationScreen> {
  final ImagePicker _picker = ImagePicker();
  final DiagnosisService _diagnosisService = DiagnosisService();
  final BackgroundRemovalService _backgroundRemoval = BackgroundRemovalService();
  bool _isProcessing = false;
  
  /// Minimum confidence threshold (5% = 0.05 on 0-1 scale)
  /// Note: confidence is stored as 0-10 scale internally
  static const double minConfidenceThreshold = 0.5; // 5% on 0-10 scale

  /// Show low confidence warning dialog
  Future<void> _showLowConfidenceWarning(BuildContext context, dynamic result) async {
    final theme = Theme.of(context);
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Düşük Güvenilirlik',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teşhis sonucu düşük güvenilirlikte (%${((result['confidence'] as double) * 10).toStringAsFixed(0)}).\n',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              'Daha iyi sonuç için öneriler:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildTip(context, Icons.pan_tool_outlined, 'Yaprağın arkasına elinizi koyun'),
            _buildTip(context, Icons.wb_sunny_outlined, 'İyi aydınlatılmış ortam kullanın'),
            _buildTip(context, Icons.center_focus_strong, 'Yaprağı yakından ve net çekin'),
            _buildTip(context, Icons.crop_free, 'Tek bir yaprak olacak şekilde kadrajlayın'),
            _buildTip(context, Icons.blur_off, 'Bulanık olmayan fotoğraf çekin'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Go back to allow retaking photo
            },
            child: const Text('Tekrar Çek'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to result despite low confidence
              context.push('/diagnosis-result', extra: result);
            },
            child: const Text('Yine de Göster'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTip(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isProcessing = true;
        });

        // Start processing in background while showing loading screen
        File? processedImage;
        dynamic result;
        String? errorMessage;
        bool usedOriginalImage = false;
        
        // Create a completer to signal when processing is done
        final processingComplete = Future<void>.delayed(Duration.zero).then((_) async {
          try {
            // Remove background to simulate PlantVillage dataset conditions
            final bgResult = await _backgroundRemoval.removeBackground(File(image.path));
            processedImage = bgResult.processedImage;
            usedOriginalImage = bgResult.usedOriginal;
            
            if (bgResult.usedOriginal) {
              print('⚠️ Background removal had high foreground ratio (${(bgResult.foregroundRatio * 100).toStringAsFixed(1)}%)');
              print('   Using original image for diagnosis');
            } else {
              print('✅ Background removal successful: ${processedImage!.path}');
              print('   Foreground ratio: ${(bgResult.foregroundRatio * 100).toStringAsFixed(1)}%');
            }
          } catch (e) {
            print('Background removal failed, using original image: $e');
            processedImage = File(image.path);
            usedOriginalImage = true;
          }

          // Run diagnosis on processed image
          result = await _diagnosisService.diagnose(processedImage!.path);
        }).catchError((e) {
          errorMessage = e.toString();
        });

        // Show loading screen (non-blocking)
        if (mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              barrierDismissible: false,
              pageBuilder: (context, _, __) => ProcessingLoadingScreen(
                onComplete: () {
                  // Animation completed - we'll wait for processing
                },
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }

        // Wait for processing to complete
        await processingComplete;
        
        // Ensure minimum loading time for UX (animation is ~4 seconds)
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          
          // Close loading screen
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Hata: $errorMessage')),
            );
          } else if (result != null) {
            final confidence = result['confidence'] as double;
            
            // Check if confidence is below threshold (5% = 0.5 on 0-10 scale)
            if (confidence < minConfidenceThreshold) {
              print('⚠️ Low confidence detected: ${(confidence * 10).toStringAsFixed(1)}%');
              await _showLowConfidenceWarning(context, result);
            } else {
              // Navigate to result screen with the diagnosis result
              context.push(
                '/diagnosis-result',
                extra: result,
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        // Close loading screen if it's open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görüntü işlenirken hata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _backgroundRemoval.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'Hastalığı Tespit Et',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          strokeWidth: 2,
                          dashPattern: const [8, 4],
                          radius: const Radius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_camera,
                                    size: 64,
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Net bir fotoğraf çekin',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hastalıklı olduğunu düşündüğünüz\n yaprağı ortalayın',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Overlay Frame
                            Center(
                              child: Container(
                                width: 280,
                                height: 400,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery Button
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.photo_library_outlined),
                          onPressed: () => _pickImage(ImageSource.gallery),
                          iconSize: 28,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      
                      // Shutter Button
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.camera),
                        child: Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Flip Camera Button (Placeholder for now, or could switch camera lens)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.flip_camera_ios_outlined),
                          onPressed: () {
                            // Optional: Implement camera flip if using a custom camera controller
                            // For ImagePicker, this isn't directly controllable in the same way
                            // So we might just leave it or use it to toggle front/back preference
                            _pickImage(ImageSource.camera); // Just trigger camera for now
                          },
                          iconSize: 28,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
