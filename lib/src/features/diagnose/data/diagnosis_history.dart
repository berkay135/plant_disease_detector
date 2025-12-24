import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:plant_disease_detector/src/core/storage/local_storage_service.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/plant_disease_info.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/plant_disease_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiagnosisHistoryItem {
  final String imagePath;
  final String label;
  final double confidence;
  final PlantDiseaseInfo diseaseInfo;
  final DateTime timestamp;

  DiagnosisHistoryItem({
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.diseaseInfo,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'label': label,
      'confidence': confidence,
      'diseaseId': diseaseInfo.id,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DiagnosisHistoryItem.fromJson(Map<String, dynamic> json, PlantDiseaseInfo diseaseInfo) {
    return DiagnosisHistoryItem(
      imagePath: json['imagePath'] ?? '',
      label: json['label'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      diseaseInfo: diseaseInfo,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class DiagnosisHistory extends ChangeNotifier {
  static final DiagnosisHistory _instance = DiagnosisHistory._internal();
  factory DiagnosisHistory() => _instance;
  DiagnosisHistory._internal();

  final List<DiagnosisHistoryItem> _history = [];
  static const String _storageKey = 'diagnosis_history';
  bool _isLoaded = false;

  List<DiagnosisHistoryItem> get history => List.unmodifiable(_history);

  /// Load history from persistent storage
  Future<void> loadHistory() async {
    if (_isLoaded) return;
    
    try {
      final repository = PlantDiseaseRepository();
      final existingIds = <String>{};
      
      // First load from Hive (new system - cloud synced items)
      try {
        final historyBox = LocalStorageService.historyBox;
        final hiveItems = historyBox.values.toList();
        print('📂 Loading ${hiveItems.length} items from Hive...');
        
        for (final item in hiveItems) {
          final diseaseInfo = await repository.getDiseaseById(item.diseaseId);
          if (diseaseInfo != null) {
            // Check if local file exists, otherwise use cloud URL
            String imagePath = '';
            if (item.localImagePath.isNotEmpty) {
              final localFile = File(item.localImagePath);
              if (await localFile.exists()) {
                imagePath = item.localImagePath;
              } else if (item.cloudImageUrl != null && item.cloudImageUrl!.isNotEmpty) {
                imagePath = item.cloudImageUrl!;
              }
            } else if (item.cloudImageUrl != null && item.cloudImageUrl!.isNotEmpty) {
              imagePath = item.cloudImageUrl!;
            }
            
            _history.add(DiagnosisHistoryItem(
              imagePath: imagePath,
              label: item.label,
              confidence: item.confidence,
              diseaseInfo: diseaseInfo,
              timestamp: item.createdAt,
            ));
            existingIds.add(item.id);
          }
        }
      } catch (e) {
        print('⚠️ Hive loading failed: $e');
      }
      
      // Then load from SharedPreferences (legacy system)
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_storageKey) ?? [];
      
      print('📂 Loading ${historyJson.length} items from SharedPreferences...');
      
      if (historyJson.isNotEmpty) {
        for (final jsonString in historyJson) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final diseaseId = json['diseaseId'] as String?;
            
            if (diseaseId != null) {
              final diseaseInfo = await repository.getDiseaseById(diseaseId);
              if (diseaseInfo != null) {
                _history.add(DiagnosisHistoryItem.fromJson(json, diseaseInfo));
              }
            }
          } catch (e) {
            print('⚠️ Failed to parse history item: $e');
          }
        }
      }
      
      // Sort by timestamp (newest first)
      _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      print('✅ Loaded ${_history.length} items successfully');
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to load history: $e');
      _isLoaded = true;
    }
  }

  /// Save history to persistent storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_storageKey, historyJson);
      print('💾 Saved ${_history.length} items to storage');
    } catch (e) {
      print('⚠️ Failed to save history: $e');
    }
  }

  Future<void> addDiagnosis(DiagnosisHistoryItem item) async {
    _history.insert(0, item); // Add to beginning
    if (_history.length > 50) {
      _history.removeLast(); // Keep only last 50
    }
    await _saveHistory();
    notifyListeners(); // Notify listeners (HomeScreen)
  }

  Future<void> clear() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  List<DiagnosisHistoryItem> getFiltered({String? severity, String? pathogenType}) {
    return _history.where((item) {
      if (severity != null && item.diseaseInfo.severity != severity) {
        return false;
      }
      if (pathogenType != null && item.diseaseInfo.pathogenType != pathogenType) {
        return false;
      }
      return true;
    }).toList();
  }

  List<DiagnosisHistoryItem> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _history.where((item) {
      return item.diseaseInfo.title.toLowerCase().contains(lowerQuery) ||
             item.diseaseInfo.description.toLowerCase().contains(lowerQuery) ||
             item.label.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Force reload history from storage (after sync)
  Future<void> reloadHistory() async {
    _history.clear();
    _isLoaded = false;
    await loadHistory();
  }
}
