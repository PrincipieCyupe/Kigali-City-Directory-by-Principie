import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// User profile provider
final userProfileProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  uid,
) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserProfile(uid);
});

// Auth state class
class AuthState {
  final bool isLoading;
  final User? user;
  final bool isAuthenticated;
  final bool requiresVerification;
  final String? error;

  AuthState({
    required this.isLoading,
    this.user,
    required this.isAuthenticated,
    required this.requiresVerification,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isLoading: false,
      user: null,
      isAuthenticated: false,
      requiresVerification: false,
      error: null,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    User? user,
    bool? isAuthenticated,
    bool? requiresVerification,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      requiresVerification: requiresVerification ?? this.requiresVerification,
      error: error,
    );
  }
}

// Auth notifier using Notifier from Riverpod v3
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      User? user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          requiresVerification: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to create account',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      User? user = await _authService.signIn(email: email, password: password);
      if (user != null) {
        if (user.emailVerified) {
          state = state.copyWith(
            isLoading: false,
            user: user,
            isAuthenticated: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            user: user,
            requiresVerification: true,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid email or password',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.signOut();
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkAuthStatus() async {
    User? user = _authService.currentUser;
    if (user != null) {
      if (user.emailVerified) {
        state = state.copyWith(user: user, isAuthenticated: true);
      } else {
        state = state.copyWith(user: user, requiresVerification: true);
      }
    }
  }

  void updateAuthState(User user, {required bool isAuthenticated}) {
    state = state.copyWith(
      user: user,
      isAuthenticated: isAuthenticated,
      requiresVerification: !user.emailVerified,
    );
  }

  Future<void> reloadUser() async {
    await _authService.reloadUser();
    User? user = _authService.currentUser;
    if (user != null) {
      state = state.copyWith(user: user);
      if (user.emailVerified) {
        state = state.copyWith(
          isAuthenticated: true,
          requiresVerification: false,
        );
      }
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth notifier provider
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

