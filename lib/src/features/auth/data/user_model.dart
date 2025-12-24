import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// User roles in the application
@HiveType(typeId: 0)
enum UserRole {
  @HiveField(0)
  admin,
  
  @HiveField(1)
  user,
  
  @HiveField(2)
  guest,
}

/// User model for authentication and profile data
@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String? displayName;
  
  @HiveField(3)
  final UserRole role;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime? lastSyncAt;
  
  @HiveField(6)
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.role = UserRole.user,
    required this.createdAt,
    this.lastSyncAt,
    this.avatarUrl,
  });

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;
  
  /// Check if user is guest
  bool get isGuest => role == UserRole.guest;
  
  /// Check if user is registered (not guest)
  bool get isRegistered => role != UserRole.guest;
  
  /// Get display name or email prefix
  String get displayNameOrEmail => displayName ?? email.split('@').first;

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastSyncAt,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'role': role.name,
    'created_at': createdAt.toIso8601String(),
    'avatar_url': avatarUrl,
  };
  
  /// Create from Supabase JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String?,
    role: UserRole.values.byName(json['role'] as String? ?? 'user'),
    createdAt: DateTime.parse(json['created_at'] as String),
    avatarUrl: json['avatar_url'] as String?,
  );
  
  /// Create a guest user
  factory UserModel.guest() => UserModel(
    id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
    email: 'guest@local',
    displayName: 'Misafir',
    role: UserRole.guest,
    createdAt: DateTime.now(),
  );

  @override
  String toString() => 'UserModel(id: $id, email: $email, role: ${role.name})';
}
