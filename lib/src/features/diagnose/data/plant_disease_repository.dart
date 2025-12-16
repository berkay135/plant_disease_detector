import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:plant_disease_detector/src/features/diagnose/data/plant_disease_info.dart';

class PlantDiseaseRepository {
  List<PlantDiseaseInfo>? _diseases;

  Future<void> _loadData() async {
    if (_diseases != null) return;
    
    try {
      final jsonString = await rootBundle.loadString('assets/plants.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _diseases = jsonList.map((json) => PlantDiseaseInfo.fromJson(json)).toList();
      print('Loaded ${_diseases!.length} diseases from plants.json');
    } catch (e) {
      print('Error loading plants.json: $e');
      _diseases = [];
    }
  }

  Future<PlantDiseaseInfo?> getDiseaseById(String id) async {
    await _loadData();
    
    // Normalize the id (trim whitespace and handle potential encoding issues)
    final normalizedId = id.trim();
    
    try {
      return _diseases!.firstWhere(
        (d) => d.id.trim() == normalizedId || 
               d.id.trim().toLowerCase() == normalizedId.toLowerCase(),
      );
    } catch (e) {
      // Try partial match as fallback
      try {
        return _diseases!.firstWhere(
          (d) => d.id.contains(normalizedId) || normalizedId.contains(d.id),
        );
      } catch (e) {
        print('Disease not found for id: "$normalizedId"');
        print('Available ids: ${_diseases!.map((d) => d.id).toList()}');
        return null;
      }
    }
  }

  Future<List<PlantDiseaseInfo>> getAllDiseases() async {
    await _loadData();
    return _diseases ?? [];
  }
}
