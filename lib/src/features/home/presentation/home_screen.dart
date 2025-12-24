import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/diagnosis_history.dart';
import 'package:plant_disease_detector/src/core/widgets/cached_image.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String? _selectedSeverity;
  String? _selectedPathogen;
  final DiagnosisHistory _history = DiagnosisHistory();

  @override
  void initState() {
    super.initState();
    // Listen to history changes
    _history.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    _history.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var items = _history.history;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      items = _history.search(_searchQuery);
    }

    // Apply filters
    if (_selectedSeverity != null || _selectedPathogen != null) {
      items = items.where((item) {
        if (_selectedSeverity != null && item.diseaseInfo.severity != _selectedSeverity) {
          return false;
        }
        if (_selectedPathogen != null && item.diseaseInfo.pathogenType != _selectedPathogen) {
          return false;
        }
        return true;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teşhislerim',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Geçmişi Temizle'),
                    content: const Text('Tüm geçmiş silinecek. Emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () {
                          _history.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Bitki veya hastalık ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.primary.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSeverity = _selectedSeverity == 'critical' ? null : 'critical';
                    });
                  },
                  child: _buildFilterChip(
                    context,
                    'Kritik',
                    icon: Icons.warning,
                    isSelected: _selectedSeverity == 'critical',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSeverity = _selectedSeverity == 'high' ? null : 'high';
                    });
                  },
                  child: _buildFilterChip(
                    context,
                    'Yüksek',
                    isSelected: _selectedSeverity == 'high',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPathogen = _selectedPathogen == 'fungal' ? null : 'fungal';
                    });
                  },
                  child: _buildFilterChip(
                    context,
                    'Mantar',
                    isSelected: _selectedPathogen == 'fungal',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPathogen = _selectedPathogen == 'bacterial' ? null : 'bacterial';
                    });
                  },
                  child: _buildFilterChip(
                    context,
                    'Bakteri',
                    isSelected: _selectedPathogen == 'bacterial',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPathogen = _selectedPathogen == 'viral' ? null : 'viral';
                    });
                  },
                  child: _buildFilterChip(
                    context,
                    'Virüs',
                    isSelected: _selectedPathogen == 'viral',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // History List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedSeverity != null || _selectedPathogen != null
                              ? 'Sonuç bulunamadı'
                              : 'Henüz geçmiş yok',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bitki teşhisi yapmaya başlayın',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildHistoryItem(
                        context,
                        item: item,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {IconData? icon, bool isSelected = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? theme.colorScheme.primary 
            : theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isSelected ? Colors.white : theme.colorScheme.onSurface),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required DiagnosisHistoryItem item,
  }) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    
    return GestureDetector(
      onTap: () {
        context.push('/treatment', extra: {
          'imagePath': item.imagePath,
          'diseaseInfo': item.diseaseInfo,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedImage(
                imagePath: item.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.diseaseInfo.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(item.diseaseInfo.severity),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.diseaseInfo.pathogenText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(item.confidence * 10).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateFormat.format(item.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red[700]!;
      case 'high':
        return Colors.orange[700]!;
      case 'medium':
        return Colors.amber[700]!;
      case 'low':
      default:
        return Colors.green[700]!;
    }
  }
}
