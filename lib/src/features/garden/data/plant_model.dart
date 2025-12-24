import 'package:hive/hive.dart';

/// Watering frequency options
@HiveType(typeId: 10)
enum WateringFrequency {
  @HiveField(0)
  daily,        // Her gün
  
  @HiveField(1)
  everyTwoDays, // 2 günde bir
  
  @HiveField(2)
  everyThreeDays, // 3 günde bir
  
  @HiveField(3)
  weekly,       // Haftada bir
  
  @HiveField(4)
  biweekly,     // 2 haftada bir
  
  @HiveField(5)
  monthly,      // Ayda bir
  
  @HiveField(6)
  custom,       // Özel
}

extension WateringFrequencyX on WateringFrequency {
  String get displayName {
    switch (this) {
      case WateringFrequency.daily:
        return 'Her gün';
      case WateringFrequency.everyTwoDays:
        return '2 günde bir';
      case WateringFrequency.everyThreeDays:
        return '3 günde bir';
      case WateringFrequency.weekly:
        return 'Haftada bir';
      case WateringFrequency.biweekly:
        return '2 haftada bir';
      case WateringFrequency.monthly:
        return 'Ayda bir';
      case WateringFrequency.custom:
        return 'Özel';
    }
  }
  
  int get days {
    switch (this) {
      case WateringFrequency.daily:
        return 1;
      case WateringFrequency.everyTwoDays:
        return 2;
      case WateringFrequency.everyThreeDays:
        return 3;
      case WateringFrequency.weekly:
        return 7;
      case WateringFrequency.biweekly:
        return 14;
      case WateringFrequency.monthly:
        return 30;
      case WateringFrequency.custom:
        return 1;
    }
  }
}

/// Plant model for garden tracking
@HiveType(typeId: 3)
class PlantModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? species;
  
  @HiveField(3)
  final String? location;
  
  @HiveField(4)
  final String? imageUrl;
  
  @HiveField(5)
  final String? localImagePath;
  
  @HiveField(6)
  final WateringFrequency wateringFrequency;
  
  @HiveField(7)
  final int? customWateringDays;
  
  @HiveField(8)
  final DateTime? lastWateredAt;
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final String? userId;
  
  @HiveField(11)
  final bool isSynced;
  
  @HiveField(12)
  final bool notificationsEnabled;
  
  @HiveField(13)
  final int notificationHour;
  
  @HiveField(14)
  final int notificationMinute;

  PlantModel({
    required this.id,
    required this.name,
    this.species,
    this.location,
    this.imageUrl,
    this.localImagePath,
    this.wateringFrequency = WateringFrequency.weekly,
    this.customWateringDays,
    this.lastWateredAt,
    required this.createdAt,
    this.userId,
    this.isSynced = false,
    this.notificationsEnabled = true,
    this.notificationHour = 9,
    this.notificationMinute = 0,
  });
  
  /// Get watering interval in days
  int get wateringDays => 
    wateringFrequency == WateringFrequency.custom 
      ? (customWateringDays ?? 7) 
      : wateringFrequency.days;
  
  /// Calculate next watering date
  DateTime? get nextWateringDate {
    if (lastWateredAt == null) return null;
    return lastWateredAt!.add(Duration(days: wateringDays));
  }
  
  /// Check if plant needs watering
  bool get needsWatering {
    if (lastWateredAt == null) return true;
    final next = nextWateringDate;
    if (next == null) return true;
    return DateTime.now().isAfter(next) || 
           DateTime.now().difference(next).inHours.abs() < 12;
  }
  
  /// Days until next watering (negative if overdue)
  int get daysUntilWatering {
    if (lastWateredAt == null) return 0;
    final next = nextWateringDate;
    if (next == null) return 0;
    return next.difference(DateTime.now()).inDays;
  }
  
  PlantModel copyWith({
    String? id,
    String? name,
    String? species,
    String? location,
    String? imageUrl,
    String? localImagePath,
    WateringFrequency? wateringFrequency,
    int? customWateringDays,
    DateTime? lastWateredAt,
    DateTime? createdAt,
    String? userId,
    bool? isSynced,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      wateringFrequency: wateringFrequency ?? this.wateringFrequency,
      customWateringDays: customWateringDays ?? this.customWateringDays,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }
  
  /// Convert to Supabase JSON
  Map<String, dynamic> toSupabase() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'species': species,
    'location': location,
    'image_url': imageUrl,
    'watering_frequency': wateringFrequency.name,
    'custom_watering_days': customWateringDays,
    'last_watered_at': lastWateredAt?.toIso8601String(),
    'notifications_enabled': notificationsEnabled,
    'notification_hour': notificationHour,
    'notification_minute': notificationMinute,
    'created_at': createdAt.toIso8601String(),
  };
  
  /// Create from Supabase JSON
  factory PlantModel.fromSupabase(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String,
      species: json['species'] as String?,
      location: json['location'] as String?,
      imageUrl: json['image_url'] as String?,
      wateringFrequency: WateringFrequency.values.firstWhere(
        (e) => e.name == json['watering_frequency'],
        orElse: () => WateringFrequency.weekly,
      ),
      customWateringDays: json['custom_watering_days'] as int?,
      lastWateredAt: json['last_watered_at'] != null 
        ? DateTime.parse(json['last_watered_at']) 
        : null,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      notificationHour: json['notification_hour'] as int? ?? 9,
      notificationMinute: json['notification_minute'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      isSynced: true,
    );
  }
  
  @override
  String toString() => 'PlantModel(id: $id, name: $name, needsWatering: $needsWatering)';
}

/// Plant note model
@HiveType(typeId: 4)
class PlantNote extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String plantId;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final String? imageUrl;
  
  @HiveField(4)
  final String? localImagePath;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final String? userId;
  
  @HiveField(7)
  final bool isSynced;
  
  @HiveField(8)
  final NoteType type;

  PlantNote({
    required this.id,
    required this.plantId,
    required this.content,
    this.imageUrl,
    this.localImagePath,
    required this.createdAt,
    this.userId,
    this.isSynced = false,
    this.type = NoteType.general,
  });
  
  PlantNote copyWith({
    String? id,
    String? plantId,
    String? content,
    String? imageUrl,
    String? localImagePath,
    DateTime? createdAt,
    String? userId,
    bool? isSynced,
    NoteType? type,
  }) {
    return PlantNote(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      type: type ?? this.type,
    );
  }
  
  /// Convert to Supabase JSON
  Map<String, dynamic> toSupabase() => {
    'id': id,
    'plant_id': plantId,
    'user_id': userId,
    'content': content,
    'image_url': imageUrl,
    'note_type': type.name,
    'created_at': createdAt.toIso8601String(),
  };
  
  /// Create from Supabase JSON
  factory PlantNote.fromSupabase(Map<String, dynamic> json) {
    return PlantNote(
      id: json['id'] as String,
      plantId: json['plant_id'] as String,
      userId: json['user_id'] as String?,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      type: NoteType.values.firstWhere(
        (e) => e.name == json['note_type'],
        orElse: () => NoteType.general,
      ),
      createdAt: DateTime.parse(json['created_at']),
      isSynced: true,
    );
  }
}

/// Note type enum
@HiveType(typeId: 11)
enum NoteType {
  @HiveField(0)
  general,      // Genel not
  
  @HiveField(1)
  watering,     // Sulama
  
  @HiveField(2)
  fertilizing,  // Gübreleme
  
  @HiveField(3)
  pruning,      // Budama
  
  @HiveField(4)
  repotting,    // Saksı değiştirme
  
  @HiveField(5)
  disease,      // Hastalık
  
  @HiveField(6)
  harvest,      // Hasat
}

extension NoteTypeX on NoteType {
  String get displayName {
    switch (this) {
      case NoteType.general:
        return 'Genel';
      case NoteType.watering:
        return 'Sulama';
      case NoteType.fertilizing:
        return 'Gübreleme';
      case NoteType.pruning:
        return 'Budama';
      case NoteType.repotting:
        return 'Saksı Değiştirme';
      case NoteType.disease:
        return 'Hastalık';
      case NoteType.harvest:
        return 'Hasat';
    }
  }
  
  String get icon {
    switch (this) {
      case NoteType.general:
        return '📝';
      case NoteType.watering:
        return '💧';
      case NoteType.fertilizing:
        return '🌿';
      case NoteType.pruning:
        return '✂️';
      case NoteType.repotting:
        return '🪴';
      case NoteType.disease:
        return '🦠';
      case NoteType.harvest:
        return '🍅';
    }
  }
}
