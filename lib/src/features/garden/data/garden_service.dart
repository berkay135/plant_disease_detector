import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:plant_disease_detector/src/core/supabase/supabase_config.dart';
import 'package:plant_disease_detector/src/core/services/image_compress_service.dart';
import 'package:plant_disease_detector/src/features/garden/data/plant_model.dart';

/// Service for managing garden plants
class GardenService {
  static const String plantsBoxName = 'plants_box';
  static const String notesBoxName = 'plant_notes_box';
  static const _uuid = Uuid();
  
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Hive boxes
  Box<PlantModel>? _plantsBox;
  Box<PlantNote>? _notesBox;
  
  Box<PlantModel> get plantsBox {
    _plantsBox ??= Hive.box<PlantModel>(plantsBoxName);
    return _plantsBox!;
  }
  
  Box<PlantNote> get notesBox {
    _notesBox ??= Hive.box<PlantNote>(notesBoxName);
    return _notesBox!;
  }
  
  // ==================== Plants CRUD ====================
  
  /// Get all plants for a user
  List<PlantModel> getPlants({String? userId}) {
    if (userId == null) {
      return plantsBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return plantsBox.values
        .where((p) => p.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Get plants that need watering
  List<PlantModel> getPlantsNeedingWater({String? userId}) {
    return getPlants(userId: userId)
        .where((p) => p.needsWatering)
        .toList();
  }
  
  /// Get a single plant by ID
  PlantModel? getPlant(String id) {
    try {
      return plantsBox.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Add a new plant
  Future<PlantModel> addPlant({
    required String name,
    String? species,
    String? location,
    String? localImagePath,
    WateringFrequency wateringFrequency = WateringFrequency.weekly,
    int? customWateringDays,
    String? userId,
    bool notificationsEnabled = true,
    int notificationHour = 9,
    int notificationMinute = 0,
  }) async {
    final plant = PlantModel(
      id: _uuid.v4(),
      name: name,
      species: species,
      location: location,
      localImagePath: localImagePath,
      wateringFrequency: wateringFrequency,
      customWateringDays: customWateringDays,
      createdAt: DateTime.now(),
      userId: userId,
      notificationsEnabled: notificationsEnabled,
      notificationHour: notificationHour,
      notificationMinute: notificationMinute,
    );
    
    await plantsBox.add(plant);
    print('✅ Plant added: ${plant.name}');
    
    // Sync to cloud in background
    if (userId != null && !userId.startsWith('guest_')) {
      _syncPlantToCloud(plant);
    }
    
    return plant;
  }
  
  /// Update a plant
  Future<PlantModel> updatePlant(PlantModel plant) async {
    final index = plantsBox.values.toList().indexWhere((p) => p.id == plant.id);
    if (index >= 0) {
      final updatedPlant = plant.copyWith(isSynced: false);
      await plantsBox.putAt(index, updatedPlant);
      print('✅ Plant updated: ${plant.name}');
      
      // Sync to cloud
      if (plant.userId != null && !plant.userId!.startsWith('guest_')) {
        _syncPlantToCloud(updatedPlant);
      }
      
      return updatedPlant;
    }
    return plant;
  }
  
  /// Mark plant as watered
  Future<PlantModel> waterPlant(String plantId) async {
    final plant = getPlant(plantId);
    if (plant == null) throw Exception('Bitki bulunamadı');
    
    final wateredPlant = plant.copyWith(
      lastWateredAt: DateTime.now(),
      isSynced: false,
    );
    
    return updatePlant(wateredPlant);
  }
  
  /// Delete a plant
  Future<void> deletePlant(String id, {String? userId}) async {
    final index = plantsBox.values.toList().indexWhere((p) => p.id == id);
    if (index >= 0) {
      await plantsBox.deleteAt(index);
      
      // Delete all notes for this plant
      final notesToDelete = notesBox.values.where((n) => n.plantId == id).toList();
      for (var note in notesToDelete) {
        final noteIndex = notesBox.values.toList().indexWhere((n) => n.id == note.id);
        if (noteIndex >= 0) {
          await notesBox.deleteAt(noteIndex);
        }
      }
      
      print('✅ Plant deleted: $id');
      
      // Delete from cloud
      if (userId != null && !userId.startsWith('guest_')) {
        _deletePlantFromCloud(id, userId);
      }
    }
  }
  
  // ==================== Notes CRUD ====================
  
  /// Get notes for a plant
  List<PlantNote> getNotesForPlant(String plantId) {
    return notesBox.values
        .where((n) => n.plantId == plantId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Add a note to a plant
  Future<PlantNote> addNote({
    required String plantId,
    required String content,
    String? localImagePath,
    NoteType type = NoteType.general,
    String? userId,
  }) async {
    final note = PlantNote(
      id: _uuid.v4(),
      plantId: plantId,
      content: content,
      localImagePath: localImagePath,
      type: type,
      createdAt: DateTime.now(),
      userId: userId,
    );
    
    await notesBox.add(note);
    print('✅ Note added to plant: $plantId');
    
    // Sync to cloud
    if (userId != null && !userId.startsWith('guest_')) {
      _syncNoteToCloud(note);
    }
    
    return note;
  }
  
  /// Delete a note
  Future<void> deleteNote(String id, {String? userId}) async {
    final index = notesBox.values.toList().indexWhere((n) => n.id == id);
    if (index >= 0) {
      await notesBox.deleteAt(index);
      print('✅ Note deleted: $id');
      
      // Delete from cloud
      if (userId != null && !userId.startsWith('guest_')) {
        _deleteNoteFromCloud(id, userId);
      }
    }
  }
  
  // ==================== Cloud Sync ====================
  
  Future<void> _syncPlantToCloud(PlantModel plant) async {
    try {
      String? imageUrl;
      
      // Upload image if exists
      if (plant.localImagePath != null && plant.localImagePath!.isNotEmpty) {
        final file = File(plant.localImagePath!);
        if (await file.exists()) {
          final compressedFile = await ImageCompressService.compressForUpload(
            file: file,
            isAvatar: false,
          );
          
          if (compressedFile != null) {
            final storagePath = '${plant.userId}/plants/${plant.id}.jpg';
            await _supabase.storage
                .from(SupabaseConfig.storageBucket)
                .upload(storagePath, compressedFile, fileOptions: const FileOptions(upsert: true));
            
            imageUrl = _supabase.storage
                .from(SupabaseConfig.storageBucket)
                .getPublicUrl(storagePath);
          }
        }
      }
      
      final syncedPlant = plant.copyWith(
        imageUrl: imageUrl ?? plant.imageUrl,
        isSynced: true,
      );
      
      await _supabase.from('plants').upsert(syncedPlant.toSupabase());
      
      // Update local storage
      final index = plantsBox.values.toList().indexWhere((p) => p.id == plant.id);
      if (index >= 0) {
        await plantsBox.putAt(index, syncedPlant);
      }
      
      print('✅ Plant synced to cloud: ${plant.name}');
    } catch (e) {
      print('⚠️ Plant sync failed: $e');
    }
  }
  
  Future<void> _deletePlantFromCloud(String id, String userId) async {
    try {
      await _supabase.from('plants').delete().eq('id', id);
      await _supabase.from('plant_notes').delete().eq('plant_id', id);
      
      // Delete image
      try {
        await _supabase.storage
            .from(SupabaseConfig.storageBucket)
            .remove(['$userId/plants/$id.jpg']);
      } catch (_) {}
      
      print('✅ Plant deleted from cloud: $id');
    } catch (e) {
      print('⚠️ Cloud delete failed: $e');
    }
  }
  
  Future<void> _syncNoteToCloud(PlantNote note) async {
    try {
      String? imageUrl;
      
      if (note.localImagePath != null && note.localImagePath!.isNotEmpty) {
        final file = File(note.localImagePath!);
        if (await file.exists()) {
          final compressedFile = await ImageCompressService.compressForUpload(
            file: file,
            isAvatar: false,
          );
          
          if (compressedFile != null) {
            final storagePath = '${note.userId}/notes/${note.id}.jpg';
            await _supabase.storage
                .from(SupabaseConfig.storageBucket)
                .upload(storagePath, compressedFile, fileOptions: const FileOptions(upsert: true));
            
            imageUrl = _supabase.storage
                .from(SupabaseConfig.storageBucket)
                .getPublicUrl(storagePath);
          }
        }
      }
      
      final syncedNote = note.copyWith(
        imageUrl: imageUrl ?? note.imageUrl,
        isSynced: true,
      );
      
      await _supabase.from('plant_notes').upsert(syncedNote.toSupabase());
      
      // Update local
      final index = notesBox.values.toList().indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        await notesBox.putAt(index, syncedNote);
      }
      
      print('✅ Note synced to cloud: ${note.id}');
    } catch (e) {
      print('⚠️ Note sync failed: $e');
    }
  }
  
  Future<void> _deleteNoteFromCloud(String id, String userId) async {
    try {
      await _supabase.from('plant_notes').delete().eq('id', id);
      print('✅ Note deleted from cloud: $id');
    } catch (e) {
      print('⚠️ Note cloud delete failed: $e');
    }
  }
  
  /// Sync all plants from cloud (for new device)
  Future<int> syncFromCloud(String userId) async {
    try {
      // Fetch plants
      final cloudPlants = await _supabase
          .from('plants')
          .select()
          .eq('user_id', userId);
      
      int newCount = 0;
      final localIds = plantsBox.values.map((p) => p.id).toSet();
      
      for (var json in cloudPlants) {
        final plantId = json['id'] as String;
        if (!localIds.contains(plantId)) {
          final plant = PlantModel.fromSupabase(json);
          await plantsBox.add(plant);
          newCount++;
        }
      }
      
      // Fetch notes
      final cloudNotes = await _supabase
          .from('plant_notes')
          .select()
          .eq('user_id', userId);
      
      final localNoteIds = notesBox.values.map((n) => n.id).toSet();
      
      for (var json in cloudNotes) {
        final noteId = json['id'] as String;
        if (!localNoteIds.contains(noteId)) {
          final note = PlantNote.fromSupabase(json);
          await notesBox.add(note);
        }
      }
      
      print('✅ Synced $newCount plants from cloud');
      return newCount;
    } catch (e) {
      print('⚠️ Sync from cloud failed: $e');
      return 0;
    }
  }
}

/// Provider for garden service
final gardenServiceProvider = Provider<GardenService>((ref) => GardenService());
