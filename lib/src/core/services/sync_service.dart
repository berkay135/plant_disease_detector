import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plant_disease_detector/src/core/storage/local_storage_service.dart';
import 'package:plant_disease_detector/src/core/supabase/supabase_config.dart';
import 'package:plant_disease_detector/src/core/services/image_compress_service.dart';

/// Service for syncing data between local storage and Supabase
class SyncService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Check if device has internet connection
  Future<bool> get hasConnection async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
  
  /// Sync unsynced local items to Supabase cloud
  Future<SyncResult> syncToCloud(String userId) async {
    if (!await hasConnection) {
      return SyncResult(success: false, message: 'İnternet bağlantısı yok');
    }
    
    final historyBox = LocalStorageService.historyBox;
    
    // Find items that need syncing
    final unsyncedItems = historyBox.values
      .where((item) => !item.isSynced && item.userId == userId)
      .toList();
    
    if (unsyncedItems.isEmpty) {
      return SyncResult(success: true, syncedCount: 0, message: 'Senkronize edilecek öğe yok');
    }
    
    int syncedCount = 0;
    int failedCount = 0;
    
    for (var item in unsyncedItems) {
      try {
        // Upload image to storage if exists locally
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
              final storagePath = '$userId/${item.id}.jpg';
              
              await _supabase.storage
                .from(SupabaseConfig.storageBucket)
                .upload(storagePath, compressedFile, fileOptions: const FileOptions(upsert: true));
              
              imageUrl = _supabase.storage
                .from(SupabaseConfig.storageBucket)
                .getPublicUrl(storagePath);
            }
          }
        }
        
        // Create synced version of item
        final syncedItem = item.copyWith(
          cloudImageUrl: imageUrl,
          isSynced: true,
        );
        
        // Upsert to database
        await _supabase.from('diagnosis_history').upsert(syncedItem.toSupabase());
        
        // Update local storage
        final key = item.key;
        await historyBox.put(key, syncedItem);
        
        syncedCount++;
        print('✅ Synced item: ${item.id}');
      } catch (e) {
        failedCount++;
        print('❌ Failed to sync item ${item.id}: $e');
      }
    }
    
    return SyncResult(
      success: failedCount == 0,
      syncedCount: syncedCount,
      failedCount: failedCount,
      message: 'Senkronizasyon tamamlandı: $syncedCount başarılı, $failedCount başarısız',
    );
  }
  
  /// Fetch items from Supabase cloud to local storage (for new device)
  Future<SyncResult> syncFromCloud(String userId) async {
    if (!await hasConnection) {
      return SyncResult(success: false, message: 'İnternet bağlantısı yok');
    }
    
    try {
      // Fetch all items for this user from cloud
      final cloudItems = await _supabase
        .from('diagnosis_history')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
      
      final historyBox = LocalStorageService.historyBox;
      
      // Get existing local item IDs
      final localIds = historyBox.values.map((e) => e.id).toSet();
      
      int newItemsCount = 0;
      
      for (var json in cloudItems) {
        final itemId = json['id'] as String;
        
        // Only add if not already local
        if (!localIds.contains(itemId)) {
          final item = DiagnosisHistoryItemCache.fromSupabase(json);
          await historyBox.add(item);
          newItemsCount++;
          print('✅ Downloaded item: $itemId');
        }
      }
      
      return SyncResult(
        success: true,
        syncedCount: newItemsCount,
        message: 'Buluttan $newItemsCount yeni öğe indirildi',
      );
    } catch (e) {
      print('❌ Failed to sync from cloud: $e');
      return SyncResult(success: false, message: 'Bulut senkronizasyonu başarısız: $e');
    }
  }
  
  /// Full bidirectional sync
  Future<SyncResult> fullSync(String userId) async {
    // First, upload local changes to cloud
    final uploadResult = await syncToCloud(userId);
    
    // Then, download any new items from cloud
    final downloadResult = await syncFromCloud(userId);
    
    return SyncResult(
      success: uploadResult.success && downloadResult.success,
      syncedCount: uploadResult.syncedCount + downloadResult.syncedCount,
      failedCount: uploadResult.failedCount + downloadResult.failedCount,
      message: 'Yüklenen: ${uploadResult.syncedCount}, İndirilen: ${downloadResult.syncedCount}',
    );
  }
  
  /// Delete item from cloud
  Future<bool> deleteFromCloud(String itemId, String userId) async {
    if (!await hasConnection) return false;
    
    try {
      // Delete from database
      await _supabase
        .from('diagnosis_history')
        .delete()
        .eq('id', itemId)
        .eq('user_id', userId);
      
      // Delete image from storage
      try {
        await _supabase.storage
          .from(SupabaseConfig.storageBucket)
          .remove(['$userId/$itemId.png']);
      } catch (e) {
        // Image might not exist, ignore
      }
      
      print('✅ Deleted from cloud: $itemId');
      return true;
    } catch (e) {
      print('❌ Failed to delete from cloud: $e');
      return false;
    }
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String message;
  
  SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.message = '',
  });
  
  @override
  String toString() => 'SyncResult(success: $success, synced: $syncedCount, failed: $failedCount)';
}

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

/// Sync status state
enum SyncStatus { idle, syncing, success, error }

/// Sync state
class SyncState {
  final SyncStatus status;
  final String? message;
  final DateTime? lastSyncAt;
  
  const SyncState({
    this.status = SyncStatus.idle,
    this.message,
    this.lastSyncAt,
  });
  
  SyncState copyWith({
    SyncStatus? status,
    String? message,
    DateTime? lastSyncAt,
  }) {
    return SyncState(
      status: status ?? this.status,
      message: message ?? this.message,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

/// Sync state notifier for UI feedback
class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => const SyncState();
  
  Future<void> sync(String userId) async {
    state = state.copyWith(status: SyncStatus.syncing, message: 'Senkronize ediliyor...');
    
    final syncService = ref.read(syncServiceProvider);
    final result = await syncService.fullSync(userId);
    
    state = SyncState(
      status: result.success ? SyncStatus.success : SyncStatus.error,
      message: result.message,
      lastSyncAt: result.success ? DateTime.now() : state.lastSyncAt,
    );
    
    // Reset to idle after a delay
    await Future.delayed(const Duration(seconds: 3));
    if (state.status != SyncStatus.syncing) {
      state = state.copyWith(status: SyncStatus.idle);
    }
  }
}

final syncNotifierProvider = NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);
