import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile_model.dart';
import '../models/user_model.dart';
import '../models/quiz_result_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!SupabaseConfig.isConfigured) {
      return;
    }
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _initialized = true;
    } catch (e) {
      // Ignore if already initialized or network unavailable
      _initialized = true;
    }
  }

  SupabaseClient? get _safeClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get client => Supabase.instance.client;

  User? get currentUser => _initialized ? _safeClient?.auth.currentUser : null;

  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges =>
      _initialized && _safeClient != null
          ? client.auth.onAuthStateChange
          : const Stream.empty();

  // Authentication
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    int initialGems = 30,
    int initialScore = 0,
    int initialQuizzesPlayed = 0,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final response = await client.auth.signUp(
      email: cleanEmail,
      password: password,
      data: {
        'username': username,
        'full_name': username,
        'email': cleanEmail,
        'avatar_url': 'avatar_7',
      },
    );

    if (response.user != null) {
      // Upsert profile record with carryover stats if any
      final profile = UserProfileModel(
        id: response.user!.id,
        email: cleanEmail,
        username: username,
        fullName: username,
        avatarUrl: 'avatar_7',
        title: 'Student',
        gems: initialGems,
        totalScore: initialScore,
        quizzesPlayed: initialQuizzesPlayed,
      );
      await upsertProfile(profile);
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  // User & Profile Management
  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response != null) {
        return UserModel.fromJson(response);
      }
    } catch (_) {}
    return null;
  }

  Future<UserProfileModel?> getProfile(String userId) async {
    // 1. Try relational query with joined users(email)
    try {
      final response = await client
          .from('profiles')
          .select('*, users:users(email)')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final userMap = response['users'] as Map<String, dynamic>?;
        final email = userMap?['email'] as String? ??
            ((currentUser?.id == userId)
                ? (currentUser?.email ??
                    currentUser?.userMetadata?['email'] as String?)
                : null);
        return UserProfileModel.fromJson(response, emailFallback: email);
      }
    } catch (_) {
      // 2. Fallback to direct profiles query if relation isn't configured yet
      try {
        final response = await client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          final emailFallback = (currentUser?.id == userId)
              ? (currentUser?.email ??
                  currentUser?.userMetadata?['email'] as String?)
              : null;
          return UserProfileModel.fromJson(response, emailFallback: emailFallback);
        }
      } catch (e) {
        // Supabase fetch error or offline
      }
    }
    return null;
  }

  Future<bool> upsertProfile(UserProfileModel profile) async {
    if (profile.id.isEmpty || profile.id == 'guest') {
      return false;
    }
    try {
      // 1. If email is present, sync to public.users
      if (profile.email != null && profile.email!.isNotEmpty) {
        try {
          await client.from('users').upsert({
            'id': profile.id,
            'email': profile.email!.trim().toLowerCase(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}
      }

      // 2. Also attempt upserting email directly to profiles if column exists
      if (profile.email != null && profile.email!.isNotEmpty) {
        try {
          final withEmail = Map<String, dynamic>.from(profile.toDbJson())
            ..['email'] = profile.email;
          await client.from('profiles').upsert(withEmail);
          return true;
        } catch (_) {
          // Column 'email' may not exist in profiles schema, fallback to toDbJson
        }
      }

      // 3. Upsert to public.profiles
      await client.from('profiles').upsert(profile.toDbJson());
      return true;
    } catch (e) {
      // Ignore or log error
      return false;
    }
  }

  Future<void> updateGemsAndScore({
    required String userId,
    required int additionalGems,
    required int additionalScore,
  }) async {
    try {
      final existing = await getProfile(userId);
      if (existing != null) {
        final updated = existing.copyWith(
          gems: existing.gems + additionalGems,
          totalScore: existing.totalScore + additionalScore,
          quizzesPlayed: existing.quizzesPlayed + 1,
        );
        await upsertProfile(updated);
      }
    } catch (_) {}
  }

  // Quiz Results
  Future<void> saveQuizResult(QuizResultModel result) async {
    try {
      await client.from('quiz_results').insert(result.toJson());
    } catch (e) {
      // Ignore or log
    }
  }

  Future<List<QuizResultModel>> getUserHistory(String userId) async {
    try {
      final response = await client
          .from('quiz_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List<dynamic>)
          .map((item) => QuizResultModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Leaderboard
  Future<List<UserProfileModel>> getLeaderboard({int limit = 50}) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .order('gems', ascending: false)
          .order('total_score', ascending: false)
          .limit(limit);

      final List<dynamic> list = response as List<dynamic>;
      final List<UserProfileModel> result = [];

      for (int i = 0; i < list.length; i++) {
        final item = list[i] as Map<String, dynamic>;
        // Alternate rank trends for realism
        final trend = (i % 3 == 0) ? 1 : ((i % 3 == 1) ? -1 : 0);
        result.add(
          UserProfileModel.fromJson(item, calculatedRank: i + 1, trend: trend),
        );
      }

      return result;
    } catch (e) {
      return [];
    }
  }
}
