import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plant_disease_detector/src/core/storage/local_storage_service.dart';
import 'package:plant_disease_detector/src/core/supabase/supabase_config.dart';
import 'package:plant_disease_detector/src/features/auth/data/user_model.dart';

/// Repository for authentication operations
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Get current user from local storage
  UserModel? get currentUser => LocalStorageService.currentUser;
  
  /// Check if user is logged in (not guest)
  bool get isLoggedIn => currentUser != null && !currentUser!.isGuest;
  
  /// Check if current user is guest
  bool get isGuest => currentUser?.isGuest ?? true;
  
  /// Check if current user is admin
  bool get isAdmin => currentUser?.isAdmin ?? false;

  // ==================== Email/Password Auth ====================
  
  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Kayıt başarısız oldu');
      }
      
      // Create user profile in database
      final user = UserModel(
        id: response.user!.id,
        email: email,
        displayName: displayName,
        role: UserRole.user,
        createdAt: DateTime.now(),
      );
      
      await _supabase.from('profiles').insert(user.toJson());
      await LocalStorageService.saveCurrentUser(user);
      
      print('✅ User signed up: ${user.email}');
      return user;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Giriş başarısız oldu');
      }
      
      // Fetch profile from database
      final profileData = await _supabase
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .single();
      
      final user = UserModel.fromJson(profileData);
      await LocalStorageService.saveCurrentUser(user);
      
      print('✅ User signed in: ${user.email} (${user.role.name})');
      return user;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } on PostgrestException catch (e) {
      // Profile might not exist, create it
      if (e.code == 'PGRST116') {
        final authUser = _supabase.auth.currentUser!;
        final user = UserModel(
          id: authUser.id,
          email: authUser.email!,
          role: UserRole.user,
          createdAt: DateTime.now(),
        );
        await _supabase.from('profiles').insert(user.toJson());
        await LocalStorageService.saveCurrentUser(user);
        return user;
      }
      rethrow;
    }
  }
  
  // ==================== Google Sign In ====================
  
  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: SupabaseConfig.googleClientId,
        scopes: ['email', 'profile'],
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google giriş iptal edildi');
      }
      
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      
      if (idToken == null) {
        throw Exception('Google kimlik doğrulaması başarısız');
      }
      
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      if (response.user == null) {
        throw Exception('Supabase Google giriş başarısız');
      }
      
      // Check if profile exists, create if not
      UserModel user;
      try {
        final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();
        user = UserModel.fromJson(profileData);
      } on PostgrestException {
        // Create new profile for Google user
        user = UserModel(
          id: response.user!.id,
          email: response.user!.email ?? googleUser.email,
          displayName: googleUser.displayName,
          avatarUrl: googleUser.photoUrl,
          role: UserRole.user,
          createdAt: DateTime.now(),
        );
        await _supabase.from('profiles').insert(user.toJson());
      }
      
      await LocalStorageService.saveCurrentUser(user);
      print('✅ User signed in with Google: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Google sign in error: $e');
      rethrow;
    }
  }
  
  // ==================== Guest Login ====================
  
  /// Continue as guest (local only, no Supabase)
  Future<UserModel> continueAsGuest() async {
    final guest = UserModel.guest();
    await LocalStorageService.saveCurrentUser(guest);
    print('✅ Continuing as guest: ${guest.id}');
    return guest;
  }
  
  // ==================== Password Reset ====================
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      print('✅ Password reset email sent to: $email');
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // ==================== Sign Out ====================
  
  /// Sign out current user
  Future<void> signOut() async {
    final user = currentUser;
    
    if (user != null && !user.isGuest) {
      await _supabase.auth.signOut();
      
      // Also sign out from Google if signed in
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    }
    
    await LocalStorageService.clearCurrentUser();
    print('✅ User signed out');
  }
  
  // ==================== Guest Migration ====================
  
  /// Migrate guest data to registered user
  Future<void> migrateGuestData(String oldGuestId, String newUserId) async {
    final historyBox = LocalStorageService.historyBox;
    
    final guestItems = historyBox.values
      .where((item) => item.userId == oldGuestId || item.userId == null)
      .toList();
    
    for (var item in guestItems) {
      final updated = item.copyWith(userId: newUserId, isSynced: false);
      final key = item.key;
      await historyBox.put(key, updated);
    }
    
    print('✅ Migrated ${guestItems.length} items from guest to user');
  }
  
  /// Convert guest account to registered user
  Future<UserModel> convertGuestToUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final oldGuestId = currentUser?.id;
    
    // Sign up as new user
    final newUser = await signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    
    // Migrate guest data
    if (oldGuestId != null) {
      await migrateGuestData(oldGuestId, newUser.id);
    }
    
    return newUser;
  }
  
  // ==================== Profile Update ====================
  
  /// Update user profile
  Future<UserModel> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null || user.isGuest) {
      throw Exception('Profil güncellemek için giriş yapmalısınız');
    }
    
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    
    await _supabase
      .from('profiles')
      .update(updates)
      .eq('id', user.id);
    
    final updatedUser = user.copyWith(
      displayName: displayName ?? user.displayName,
      avatarUrl: avatarUrl ?? user.avatarUrl,
    );
    await LocalStorageService.saveCurrentUser(updatedUser);
    
    return updatedUser;
  }
  
  // ==================== Error Handling ====================
  
  /// Handle Supabase auth errors and return user-friendly messages
  Exception _handleAuthError(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return Exception('E-posta veya şifre hatalı');
      case 'User already registered':
        return Exception('Bu e-posta adresi zaten kayıtlı');
      case 'Password should be at least 6 characters':
        return Exception('Şifre en az 6 karakter olmalıdır');
      case 'Unable to validate email address: invalid format':
        return Exception('Geçersiz e-posta formatı');
      default:
        return Exception(e.message);
    }
  }
}
