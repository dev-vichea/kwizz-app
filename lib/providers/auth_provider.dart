import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final StorageService _storageService = StorageService();

  StreamSubscription<AuthState>? _authSubscription;
  UserProfileModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _supabaseService.isAuthenticated;

  // Default guest profile when not logged in
  UserProfileModel get defaultProfile => UserProfileModel(
        id: 'guest',
        username: 'Guest Player',
        fullName: 'Guest Player',
        avatarUrl: 'girl_reading',
        title: 'Guest',
        gems: 0,
        totalScore: 0,
        quizzesPlayed: 0,
        rank: null,
      );

  AuthProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedLocal = await _storageService.getSavedLocalProfile();
      if (_supabaseService.isAuthenticated) {
        final user = _supabaseService.currentUser!;
        final profile = await _supabaseService.getProfile(user.id);
        if (profile != null) {
          _userProfile = profile.copyWith(email: user.email);
        } else {
          _userProfile = (savedLocal ?? defaultProfile).copyWith(
            id: user.id,
            email: user.email,
          );
        }
      } else {
        _userProfile = savedLocal ?? defaultProfile;
      }
    } catch (_) {
      _userProfile = defaultProfile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Subscribe to auth state updates
    _authSubscription?.cancel();
    _authSubscription = _supabaseService.authStateChanges.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.userUpdated) {
        final user = data.session?.user ?? _supabaseService.currentUser;
        if (user != null && (_userProfile == null || _userProfile!.id != user.id || _userProfile!.email == null)) {
          final profile = await _supabaseService.getProfile(user.id);
          if (profile != null) {
            _userProfile = profile.copyWith(email: user.email);
            await _storageService.saveLocalProfile(_userProfile!);
            notifyListeners();
          }
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _userProfile = defaultProfile;
        await _storageService.saveLocalProfile(_userProfile!);
        notifyListeners();
      }
    });
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _supabaseService.signIn(email: cleanEmail, password: password);
      if (res.user != null) {
        final profile = await _supabaseService.getProfile(res.user!.id);
        _userProfile = profile?.copyWith(email: cleanEmail) ??
            defaultProfile.copyWith(
              id: res.user!.id,
              email: cleanEmail,
              username: res.user!.userMetadata?['username'] ?? cleanEmail.split('@').first,
            );
        await _storageService.saveLocalProfile(_userProfile!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = _parseAuthError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp(String email, String password, String username) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanUsername = username.trim();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Migrate guest progress if the user had played before signing up
      final int carryoverGems = (_userProfile != null && _userProfile!.gems > 30)
          ? _userProfile!.gems
          : 30;
      final int carryoverScore = _userProfile?.totalScore ?? 0;
      final int carryoverQuizzes = _userProfile?.quizzesPlayed ?? 0;

      final res = await _supabaseService.signUp(
        email: cleanEmail,
        password: password,
        username: cleanUsername,
        initialGems: carryoverGems,
        initialScore: carryoverScore,
        initialQuizzesPlayed: carryoverQuizzes,
      );

      if (res.user != null) {
        _userProfile = UserProfileModel(
          id: res.user!.id,
          email: cleanEmail,
          username: cleanUsername,
          fullName: cleanUsername,
          avatarUrl: 'avatar_7',
          title: 'Student',
          gems: carryoverGems,
          totalScore: carryoverScore,
          quizzesPlayed: carryoverQuizzes,
        );
        await _storageService.saveLocalProfile(_userProfile!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = _parseAuthError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> resetPassword(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.resetPassword(cleanEmail);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (_) {}
    _userProfile = defaultProfile;
    await _storageService.saveLocalProfile(_userProfile!);
    notifyListeners();
  }

  void continueAsGuest() {
    // Retain existing guest stats if present, otherwise default
    if (_userProfile == null || _userProfile!.id != 'guest') {
      _userProfile = defaultProfile;
    }
    _storageService.saveLocalProfile(_userProfile!);
    notifyListeners();
  }

  Future<void> addGemsAndScore({
    required int earnedGems,
    required int earnedScore,
  }) async {
    if (_userProfile == null) return;

    final updated = _userProfile!.copyWith(
      gems: _userProfile!.gems + earnedGems,
      totalScore: _userProfile!.totalScore + earnedScore,
      quizzesPlayed: _userProfile!.quizzesPlayed + 1,
    );
    _userProfile = updated;
    notifyListeners();

    // Persist locally
    await _storageService.saveLocalProfile(updated);

    // Sync to Supabase if authenticated
    if (updated.id.isNotEmpty && updated.id != 'guest') {
      try {
        await _supabaseService.upsertProfile(updated);
      } catch (_) {}
    }
  }

  Future<void> updateAvatar(String newAvatarUrl) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(avatarUrl: newAvatarUrl);
    notifyListeners();
    await _storageService.saveLocalProfile(_userProfile!);
    if (_userProfile!.id.isNotEmpty && _userProfile!.id != 'guest') {
      await _supabaseService.upsertProfile(_userProfile!);
    }
  }

  Future<void> updateProfile({String? username, String? title}) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(
      username: username ?? _userProfile!.username,
      title: title ?? _userProfile!.title,
    );
    notifyListeners();
    await _storageService.saveLocalProfile(_userProfile!);
    if (_userProfile!.id.isNotEmpty && _userProfile!.id != 'guest') {
      await _supabaseService.upsertProfile(_userProfile!);
    }
  }

  String _parseAuthError(dynamic e) {
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid grant') ||
          msg.contains('invalid_grant')) {
        return 'Incorrect email or password. Please verify your details.';
      }
      if (msg.contains('user already registered') ||
          msg.contains('user_already_exists') ||
          msg.contains('already registered')) {
        return 'An account with this email already exists. Try signing in.';
      }
      if (msg.contains('password should be at least') ||
          msg.contains('weak_password')) {
        return 'Password must be at least 6 characters long.';
      }
      if (msg.contains('rate limit') || msg.contains('too many requests')) {
        return 'Too many attempts. If this account already exists, switch to Sign In! Tip: In Supabase Dashboard, disable "Confirm email" under Auth -> Providers -> Email to remove this limit.';
      }
      if (msg.contains('valid email')) {
        return 'Please enter a valid email address.';
      }
      return e.message;
    }
    final raw = e.toString().replaceAll('Exception: ', '').trim();
    if (raw.toLowerCase().contains('socket') || raw.toLowerCase().contains('network')) {
      return 'Network connection issue. Please check your internet connection.';
    }
    return raw;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
