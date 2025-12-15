import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_disease_detector/src/core/theme/app_theme.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/diagnosis_service.dart';

class PlantIdentificationScreen extends StatefulWidget {
  const PlantIdentificationScreen({super.key});

  @override
  State<PlantIdentificationScreen> createState() => _PlantIdentificationScreenState();
}

class _PlantIdentificationScreenState extends State<PlantIdentificationScreen> {
  final ImagePicker _picker = ImagePicker();
  final DiagnosisService _diagnosisService = DiagnosisService();
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isProcessing = true;
        });

        // Run diagnosis
        final result = await _diagnosisService.diagnose(image.path);

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          
          // Navigate to result screen with the diagnosis result
          context.push(
            '/diagnosis-result',
            extra: result,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    }
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
                          'Identify Plant',
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
                                    'Take a clear photo',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Frame the diseased part of your plant\nwithin the box.',
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
