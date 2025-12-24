import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_disease_detector/src/core/theme/app_theme.dart';
import 'package:plant_disease_detector/src/core/widgets/cached_image.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/plant_disease_info.dart';

class TreatmentScreen extends StatefulWidget {
  final String imagePath;
  final PlantDiseaseInfo diseaseInfo;

  const TreatmentScreen({
    super.key,
    required this.imagePath,
    required this.diseaseInfo,
  });

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: isDark 
                  ? AppTheme.backgroundDark.withValues(alpha: 0.8) 
                  : Colors.white.withValues(alpha: 0.8),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Tedavi ve Öneri',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.ios_share),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
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
                          child: CachedImage(
                            imagePath: widget.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        widget.diseaseInfo.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Tags
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (widget.diseaseInfo.severity != 'low')
                            _buildTag(
                              context,
                              widget.diseaseInfo.severityText,
                              _getSeverityColor(widget.diseaseInfo.severity, isDark),
                              _getSeverityTextColor(widget.diseaseInfo.severity, isDark),
                            ),
                          if (!widget.diseaseInfo.isHealthy)
                            _buildTag(
                              context,
                              widget.diseaseInfo.pathogenText,
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                              theme.colorScheme.onSurface,
                            ),
                        ],
                      ),
                    ),

                    // Description
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.diseaseInfo.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Tab Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _buildTabButton(0, 'Tedavi', isDark),
                            _buildTabButton(1, 'Bakım', isDark),
                            _buildTabButton(2, 'Ürünler', isDark),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tab Content
                    _buildTabContent(context, isDark),

                    // Feedback Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Bu çözüm işe yaradı mı?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.thumb_up_outlined),
                                  label: const Text('Evet'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    side: BorderSide(color: theme.colorScheme.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.thumb_down_outlined),
                                  label: const Text('Hayır'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    side: BorderSide(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, bool isDark) {
    final isSelected = _selectedTab == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, bool isDark) {
    switch (_selectedTab) {
      case 0:
        return _buildTreatmentTab(context, isDark);
      case 1:
        return _buildCareTab(context, isDark);
      case 2:
        return _buildProductsTab(context, isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTreatmentTab(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Natural Solutions
          if (widget.diseaseInfo.treatment.natural.isNotEmpty) ...[
            Text(
              'Doğal Çözümler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.diseaseInfo.treatment.natural.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildStepCard(
                  context,
                  isDark,
                  (entry.key + 1).toString(),
                  entry.value,
                ),
              );
            }),
          ],

          // Chemical Solutions
          if (widget.diseaseInfo.treatment.chemical.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Kimyasal Mücadele',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.diseaseInfo.treatment.chemical.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildIconCard(
                  context,
                  isDark,
                  Icons.science,
                  'Fungisit Kullanımı',
                  item,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCareTab(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bakım Önerileri',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.diseaseInfo.care.asMap().entries.map((entry) {
            final icons = [Icons.water_drop, Icons.wb_sunny, Icons.air, Icons.eco];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildIconCard(
                context,
                isDark,
                icons[entry.key % icons.length],
                'Öneri ${entry.key + 1}',
                entry.value,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Önerilen Ürünler',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.diseaseInfo.products.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        product,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, bool isDark, String step, String description) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCard(BuildContext context, bool isDark, IconData icon, String title, String description) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity, bool isDark) {
    switch (severity) {
      case 'critical':
        return isDark ? const Color(0xFF8B1A1A) : const Color(0xFFFFEBEE);
      case 'high':
        return isDark ? const Color(0xFF582c2e) : const Color(0xFFf8d7da);
      case 'medium':
        return isDark ? const Color(0xFF66512C) : const Color(0xFFFFF3E0);
      case 'low':
      default:
        return isDark ? const Color(0xFF1B4D3E) : const Color(0xFFE8F5E9);
    }
  }

  Color _getSeverityTextColor(String severity, bool isDark) {
    switch (severity) {
      case 'critical':
        return isDark ? const Color(0xFFFFCDD2) : const Color(0xFFC62828);
      case 'high':
        return isDark ? const Color(0xFFf5c6cb) : const Color(0xFF721c24);
      case 'medium':
        return isDark ? const Color(0xFFFFD180) : const Color(0xFFE65100);
      case 'low':
      default:
        return isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32);
    }
  }
}
