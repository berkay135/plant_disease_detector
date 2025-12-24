import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_disease_detector/src/core/theme/app_theme.dart';
import 'package:plant_disease_detector/src/core/services/diagnosis_save_service.dart';
import 'package:plant_disease_detector/src/features/auth/providers/auth_provider.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/plant_disease_info.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/plant_disease_repository.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/diagnosis_history.dart';

class DiagnosisResultScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final String label;
  final double confidence;

  const DiagnosisResultScreen({
    super.key,
    required this.imagePath,
    required this.label,
    required this.confidence,
  });

  @override
  ConsumerState<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends ConsumerState<DiagnosisResultScreen> {
  final PlantDiseaseRepository _repository = PlantDiseaseRepository();
  PlantDiseaseInfo? _diseaseInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiseaseInfo();
  }

  Future<void> _loadDiseaseInfo() async {
    try {
      print('Looking for disease with label: "${widget.label}"');
      final info = await _repository.getDiseaseById(widget.label);
      print('Found disease info: ${info?.title}');
      if (mounted) {
        setState(() {
          _diseaseInfo = info;
          _isLoading = false;
        });
        
        // Add to history if disease info loaded successfully
        if (info != null) {
          // Legacy history (SharedPreferences)
          DiagnosisHistory().addDiagnosis(
            DiagnosisHistoryItem(
              imagePath: widget.imagePath,
              label: widget.label,
              confidence: widget.confidence,
              diseaseInfo: info,
              timestamp: DateTime.now(),
            ),
          );
          
          // New Hive storage + Cloud sync
          final user = ref.read(currentUserProvider);
          final saveService = ref.read(diagnosisSaveServiceProvider);
          await saveService.saveDiagnosis(
            diseaseId: info.id,
            label: widget.label,
            confidence: widget.confidence,
            localImagePath: widget.imagePath,
            userId: user?.id,
          );
        }
      }
    } catch (e) {
      print('Error loading disease info: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getConfidenceColor(double confidence) {
    final percent = confidence * 10;
    if (percent >= 8) return Colors.green;
    if (percent >= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/home'),
                  ),
                  Expanded(
                    child: Text(
                      'Sonuçlar',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // Title
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _diseaseInfo?.title ?? widget.label,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Confidence Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getConfidenceColor(widget.confidence),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '%${(widget.confidence * 10).toStringAsFixed(0)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              _diseaseInfo?.description ?? 'Hastalık bilgisi yüklenemedi.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Symptoms section
                          if (_diseaseInfo != null && _diseaseInfo!.symptoms.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Ana Belirtiler',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._diseaseInfo!.symptoms.asMap().entries.map((entry) {
                              final icons = [Icons.lens_blur, Icons.palette, Icons.eco, Icons.warning_amber];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          icons[entry.key % icons.length],
                                          color: theme.colorScheme.onSurface,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],

                          // Healthy plant message
                          if (_diseaseInfo != null && _diseaseInfo!.isHealthy) ...[
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Bitkiniz Sağlıklı!',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Herhangi bir hastalık belirtisi tespit edilmedi.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 100), // Space for button
                        ],
                      ),
                    ),
            ),

            // Bottom Button
            if (!_isLoading && _diseaseInfo != null && !_diseaseInfo!.isHealthy)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/treatment', extra: {
                          'imagePath': widget.imagePath,
                          'diseaseInfo': _diseaseInfo,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Tedavi Yöntemlerini Gör',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

