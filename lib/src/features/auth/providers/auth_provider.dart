import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plant_disease_detector/src/core/storage/local_storage_service.dart';
import 'package:plant_disease_detector/src/features/auth/data/auth_repository.dart';
import 'package:plant_disease_detector/src/features/auth/data/user_model.dart';

/// Authentication status states
enum AuthStatus {
  /// Initial state, checking for existing session
  initial,
  
  /// User is authenticated (signed in)
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
  
  /// User is using guest mode
  guest,
}

/// Authentication state
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Create a copy with updated fields
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Check if user is admin
  bool get isAdmin => user?.isAdmin ?? false;
  
  /// Check if user is guest
  bool get isGuest => status == AuthStatus.guest;
  
  /// Check if user is authenticated (not guest, not unauthenticated)
  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  String toString() => 'AuthState(status: $status, user: ${user?.email}, loading: $isLoading)';
}

/// Authentication state notifier
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  
  @override
  AuthState build() {
    _repository = AuthRepository();
    // Start with initial state and check session asynchronously
    Future.microtask(() => _checkCurrentUser());
    return const AuthState(status: AuthStatus.initial);
  }
  
  /// Check for existing user session
  Future<void> _checkCurrentUser() async {
    // First check local user (fast)
    final localUser = _repository.currentUser;
    
    // Guest user - no need for Supabase
    if (localUser != null && localUser.isGuest) {
      state = AuthState(status: AuthStatus.guest, user: localUser);
      print('✅ Restored guest session: ${localUser.id}');
      return;
    }
    
    // Check Supabase session
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    
    if (supabaseUser != null && localUser != null && !localUser.isGuest) {
      // Both Supabase and local user exist - use local (faster)
      state = AuthState(status: AuthStatus.authenticated, user: localUser);
      print('✅ Restored session: ${localUser.email} (${localUser.role.name})');
      return;
    }
    
    if (supabaseUser != null && localUser == null) {
      // Supabase has session but no local user - fetch profile
      await _restoreFromSupabase(supabaseUser);
      return;
    }
    
    // No session found
    state = const AuthState(status: AuthStatus.unauthenticated);
    print('ℹ️ No existing session found');
  }
  
  /// Restore user from Supabase session
  Future<void> _restoreFromSupabase(User supabaseUser) async {
    try {
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', supabaseUser.id)
          .single();
      
      final user = UserModel.fromJson(profileData);
      await LocalStorageService.saveCurrentUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      print('✅ Restored from Supabase: ${user.email}');
    } catch (e) {
      print('⚠️ Failed to restore from Supabase: $e');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
  
  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  /// Sign up with email and password
  Future<void> signUp(String email, String password, String? displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final user = await _repository.signInWithGoogle();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  /// Continue as guest
  Future<void> continueAsGuest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final user = await _repository.continueAsGuest();
      state = AuthState(status: AuthStatus.guest, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _repository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  /// Convert guest to registered user
  Future<void> convertGuestToUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final user = await _repository.convertGuestToUser(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  /// Update user profile
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    if (state.user == null || state.user!.isGuest) return;
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final updatedUser = await _repository.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Auth provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Shortcut provider for checking if user is admin
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});

/// Shortcut provider for checking if user is guest
final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isGuest;
});

/// Shortcut provider for current user
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
