import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService {
  static final _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = Supabase.instance.client;

  // Demo credentials
  static const String demoUsername = 'admin';
  static const String demoPassword = '123';

  // Demo user flag
  bool _isDemoUser = false;
  UserModel? _demoUserModel;

  // Get current user
  User? get currentUser => _isDemoUser ? null : _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession =>
      _isDemoUser ? null : _supabase.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => _isDemoUser || currentSession != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Check for demo credentials first
      if (email.trim().toLowerCase() == demoUsername.toLowerCase() &&
          password == demoPassword) {
        // Set demo user flag
        _isDemoUser = true;
        _demoUserModel = UserModel(
          id: 'demo-user-id',
          name: 'Admin User',
          username: 'admin',
          email: 'admin@rfidmanager.com',
          role: 'admin',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Return a mock successful response
        return AuthResponse(
          user: null, // Using demo mode, no real user
          session: null, // Using demo mode, no real session
        );
      }

      // Try real Supabase authentication for non-demo users
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isDemoUser = false;
        await _updateLastLoginTime(response.user!.id);
      }

      return response;
    } catch (e) {
      throw Exception('Login failed: Invalid email or password');
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.user != null) {
        await _createUserProfile(response.user!);
      }

      return response;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (_isDemoUser) {
        _isDemoUser = false;
        _demoUserModel = null;
        return;
      }

      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().toLowerCase() == demoUsername.toLowerCase()) {
        throw Exception('Password reset not available for demo account');
      }

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.rfidmanager://reset-callback/',
      );
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      if (_isDemoUser) {
        return _demoUserModel;
      }

      final user = currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from(AppConstants.usersTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      // Return demo user if we're in demo mode
      if (_isDemoUser) {
        return _demoUserModel;
      }
      return null;
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      if (_isDemoUser) {
        // Update demo user model
        _demoUserModel = _demoUserModel?.copyWith(
          name: name,
          phone: phone,
          address: address,
        );
        return _demoUserModel!;
      }

      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(AppConstants.usersTable)
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Private method to create user profile
  Future<void> _createUserProfile(User user) async {
    try {
      await _supabase.from(AppConstants.usersTable).insert({
        'id': user.id,
        'email': user.email,
        'first_name': user.userMetadata?['first_name'],
        'last_name': user.userMetadata?['last_name'],
        'created_at': DateTime.now().toIso8601String(),
        'role': 'user',
        'is_active': true,
      });
    } catch (e) {
      // Profile might already exist, ignore error
    }
  }

  // Private method to update last login time
  Future<void> _updateLastLoginTime(String userId) async {
    try {
      await _supabase.from(AppConstants.usersTable).update(
          {'last_login_at': DateTime.now().toIso8601String()}).eq('id', userId);
    } catch (e) {
      // Ignore errors for last login update
    }
  }

  // Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      if (_isDemoUser) {
        return AuthResponse(user: null, session: null);
      }
      return await _supabase.auth.refreshSession();
    } catch (e) {
      throw Exception('Session refresh failed: ${e.toString()}');
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      if (email.trim().toLowerCase() == demoUsername.toLowerCase()) {
        return true;
      }

      final response = await _supabase
          .from(AppConstants.usersTable)
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Check if in demo mode
  bool get isDemoMode => _isDemoUser;
}
