import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:plant_disease_detector/src/core/storage/local_storage_service.dart';
import 'package:plant_disease_detector/src/core/services/image_compress_service.dart';
import 'package:plant_disease_detector/src/core/supabase/supabase_config.dart';
import 'package:plant_disease_detector/src/features/auth/providers/auth_provider.dart';

/// Service for saving diagnosis results to local storage and cloud
class DiagnosisSaveService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Save a diagnosis to local storage (Hive) and optionally sync to cloud
  /// 
  /// Returns the created cache item
  Future<DiagnosisHistoryItemCache> saveDiagnosis({
    required String diseaseId,
    required String label,
    required double confidence,
    required String localImagePath,
    String? userId,
  }) async {
    final historyBox = LocalStorageService.historyBox;
    
    // Create unique ID for this diagnosis
    final id = _uuid.v4();
    
    // Create the cache item
    final item = DiagnosisHistoryItemCache(
      id: id,
      diseaseId: diseaseId,
      label: label,
      confidence: confidence,
      localImagePath: localImagePath,
      createdAt: DateTime.now(),
      isSynced: false,
      userId: userId,
    );
    
    // Save to local Hive storage
    await historyBox.add(item);
    print('✅ Diagnosis saved to local storage: $id');
    
    // Try to sync to cloud in background (don't wait)
    if (userId != null && !userId.startsWith('guest_')) {
      _syncToCloudInBackground(item);
    }
    
    return item;
  }
  
  /// Sync a single item to cloud in background
  Future<void> _syncToCloudInBackground(DiagnosisHistoryItemCache item) async {
    try {
      // Upload image to storage
      String? imageUrl;
      if (item.localImagePath.isNotEmpty) {
        final file = File(item.localImagePath);
        if (await file.exists()) {
          // Compress image before upload
          final compressedFile = await ImageCompressService.compressForUpload(
            file: file,
            isAvatar: false,
          );
          
          if (compressedFile != null) {
            final storagePath = '${item.userId}/${item.id}.jpg';
            
            await _supabase.storage
                .from(SupabaseConfig.storageBucket)
                .upload(storagePath, compressedFile, fileOptions: const FileOptions(upsert: true));
            
            imageUrl = _supabase.storage
                .from(SupabaseConfig.storageBucket)
                .getPublicUrl(storagePath);
            
            print('✅ Image uploaded: $storagePath');
          }
        }
      }
      
      // Create synced version
      final syncedItem = item.copyWith(
        cloudImageUrl: imageUrl,
        isSynced: true,
      );
      
      // Upsert to database
      await _supabase.from('diagnosis_history').upsert(syncedItem.toSupabase());
      
      // Update local storage to mark as synced
      final historyBox = LocalStorageService.historyBox;
      final key = historyBox.values
          .toList()
          .indexWhere((e) => e.id == item.id);
      
      if (key >= 0) {
        await historyBox.putAt(key, syncedItem);
        print('✅ Diagnosis synced to cloud: ${item.id}');
      }
    } catch (e) {
      print('⚠️ Background sync failed (will retry later): $e');
      // Don't throw - this is background sync, item is already saved locally
    }
  }
  
  /// Get all local diagnoses for a user
  List<DiagnosisHistoryItemCache> getLocalDiagnoses({String? userId}) {
    final historyBox = LocalStorageService.historyBox;
    
    if (userId == null) {
      return historyBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return historyBox.values
        .where((item) => item.userId == userId || item.userId == null)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Delete a diagnosis from local storage and cloud
  Future<void> deleteDiagnosis(String id, {String? userId}) async {
    final historyBox = LocalStorageService.historyBox;
    
    // Find and delete from local storage
    final items = historyBox.values.toList();
    final index = items.indexWhere((e) => e.id == id);
    
    if (index >= 0) {
      await historyBox.deleteAt(index);
      print('✅ Diagnosis deleted from local storage: $id');
    }
    
    // Also delete from cloud if user is authenticated
    if (userId != null && !userId.startsWith('guest_')) {
      try {
        await _supabase.from('diagnosis_history').delete().eq('id', id);
        
        // Delete image from storage
        try {
          await _supabase.storage
              .from(SupabaseConfig.storageBucket)
              .remove(['$userId/$id.jpg']);
        } catch (_) {}
        
        print('✅ Diagnosis deleted from cloud: $id');
      } catch (e) {
        print('⚠️ Cloud delete failed: $e');
      }
    }
  }
}

/// Provider for diagnosis save service
final diagnosisSaveServiceProvider = Provider<DiagnosisSaveService>((ref) {
  return DiagnosisSaveService();
});

/// Provider that returns diagnoses for current user
final userDiagnosesProvider = Provider<List<DiagnosisHistoryItemCache>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(diagnosisSaveServiceProvider);
  return service.getLocalDiagnoses(userId: user?.id);
});
