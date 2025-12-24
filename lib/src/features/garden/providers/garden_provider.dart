import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_disease_detector/src/features/auth/providers/auth_provider.dart';
import 'package:plant_disease_detector/src/features/garden/data/garden_service.dart';
import 'package:plant_disease_detector/src/features/garden/data/plant_model.dart';
import 'package:plant_disease_detector/src/core/services/notification_service.dart';

/// State for garden
class GardenState {
  final List<PlantModel> plants;
  final List<PlantModel> plantsNeedingWater;
  final bool isLoading;
  final String? errorMessage;

  const GardenState({
    this.plants = const [],
    this.plantsNeedingWater = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GardenState copyWith({
    List<PlantModel>? plants,
    List<PlantModel>? plantsNeedingWater,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GardenState(
      plants: plants ?? this.plants,
      plantsNeedingWater: plantsNeedingWater ?? this.plantsNeedingWater,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Garden state notifier
class GardenNotifier extends Notifier<GardenState> {
  GardenService get _service => ref.read(gardenServiceProvider);
  
  @override
  GardenState build() {
    // Load plants immediately (synchronous from Hive)
    final user = ref.read(currentUserProvider);
    final plants = _service.getPlants(userId: user?.id);
    final needsWater = _service.getPlantsNeedingWater(userId: user?.id);
    
    return GardenState(
      plants: plants,
      plantsNeedingWater: needsWater,
      isLoading: false,
    );
  }
  
  void _loadPlants() {
    final user = ref.read(currentUserProvider);
    final plants = _service.getPlants(userId: user?.id);
    final needsWater = _service.getPlantsNeedingWater(userId: user?.id);
    
    state = GardenState(
      plants: plants,
      plantsNeedingWater: needsWater,
      isLoading: false,
    );
  }
  
  void refresh() {
    _loadPlants();
  }
  
  Future<PlantModel> addPlant({
    required String name,
    String? species,
    String? location,
    String? localImagePath,
    WateringFrequency wateringFrequency = WateringFrequency.weekly,
    int? customWateringDays,
    bool notificationsEnabled = true,
    int notificationHour = 9,
    int notificationMinute = 0,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final user = ref.read(currentUserProvider);
      final plant = await _service.addPlant(
        name: name,
        species: species,
        location: location,
        localImagePath: localImagePath,
        wateringFrequency: wateringFrequency,
        customWateringDays: customWateringDays,
        userId: user?.id,
        notificationsEnabled: notificationsEnabled,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
      );
      
      // Schedule notification for the plant
      if (notificationsEnabled) {
        await NotificationService().scheduleWateringReminder(plant);
      }
      
      _loadPlants();
      return plant;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
  
  Future<void> updatePlant(PlantModel plant) async {
    try {
      await _service.updatePlant(plant);
      
      // Update notification for the plant
      if (plant.notificationsEnabled) {
        await NotificationService().scheduleWateringReminder(plant);
      } else {
        await NotificationService().cancelNotification(plant.id.hashCode);
      }
      
      _loadPlants();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
  
  Future<void> waterPlant(String plantId) async {
    try {
      await _service.waterPlant(plantId);
      
      // Re-schedule notification for next watering
      final plant = _service.getPlant(plantId);
      if (plant != null && plant.notificationsEnabled) {
        await NotificationService().scheduleWateringReminder(plant);
      }
      
      _loadPlants();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
  
  Future<void> deletePlant(String id) async {
    try {
      // Cancel notification for deleted plant
      await NotificationService().cancelNotification(id.hashCode);
      
      final user = ref.read(currentUserProvider);
      await _service.deletePlant(id, userId: user?.id);
      _loadPlants();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
  
  List<PlantNote> getNotesForPlant(String plantId) {
    return _service.getNotesForPlant(plantId);
  }
  
  Future<PlantNote> addNote({
    required String plantId,
    required String content,
    String? localImagePath,
    NoteType type = NoteType.general,
  }) async {
    final user = ref.read(currentUserProvider);
    return _service.addNote(
      plantId: plantId,
      content: content,
      localImagePath: localImagePath,
      type: type,
      userId: user?.id,
    );
  }
  
  Future<void> deleteNote(String id) async {
    final user = ref.read(currentUserProvider);
    await _service.deleteNote(id, userId: user?.id);
  }
}

/// Garden provider
final gardenProvider = NotifierProvider<GardenNotifier, GardenState>(
  GardenNotifier.new,
);

/// Provider for a single plant
final plantProvider = Provider.family<PlantModel?, String>((ref, id) {
  final gardenState = ref.watch(gardenProvider);
  try {
    return gardenState.plants.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

/// Provider for notes of a plant
final plantNotesProvider = Provider.family<List<PlantNote>, String>((ref, plantId) {
  final garden = ref.watch(gardenProvider.notifier);
  return garden.getNotesForPlant(plantId);
});
