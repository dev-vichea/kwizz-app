class UserProfileModel {
  final String id;
  final String? email;
  final String username;
  final String? fullName;
  final String avatarUrl;
  final String title;
  final int gems;
  final int totalScore;
  final int quizzesPlayed;
  final int? rank;
  final int rankTrend; // 1: up, -1: down, 0: stable

  UserProfileModel({
    required this.id,
    this.email,
    required this.username,
    this.fullName,
    required this.avatarUrl,
    this.title = 'Student',
    this.gems = 30,
    this.totalScore = 0,
    this.quizzesPlayed = 0,
    this.rank,
    this.rankTrend = 1,
  });

  factory UserProfileModel.fromJson(
    Map<String, dynamic> json, {
    int? calculatedRank,
    int? trend,
    String? emailFallback,
  }) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? emailFallback,
      username: json['username'] ?? 'Emily Rose',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'] ?? 'avatar_7',
      title: json['title'] ?? 'Student',
      gems: (json['gems'] is int)
          ? json['gems']
          : int.tryParse(json['gems']?.toString() ?? '30') ?? 30,
      totalScore: (json['total_score'] is int)
          ? json['total_score']
          : int.tryParse(json['total_score']?.toString() ?? '0') ?? 0,
      quizzesPlayed: (json['quizzes_played'] is int)
          ? json['quizzes_played']
          : int.tryParse(json['quizzes_played']?.toString() ?? '0') ?? 0,
      rank: calculatedRank,
      rankTrend: trend ?? 1,
    );
  }

  /// Full JSON serialization including email for SharedPreferences local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName ?? username,
      'avatar_url': avatarUrl,
      'title': title,
      'gems': gems,
      'total_score': totalScore,
      'quizzes_played': quizzesPlayed,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Supabase database schema representation for `public.profiles`.
  /// Excludes `email` to prevent Postgres schema mismatch error 42703,
  /// as Supabase stores authentication emails securely in `auth.users`.
  Map<String, dynamic> toDbJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName ?? username,
      'avatar_url': avatarUrl,
      'title': title,
      'gems': gems,
      'total_score': totalScore,
      'quizzes_played': quizzesPlayed,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? title,
    int? gems,
    int? totalScore,
    int? quizzesPlayed,
    int? rank,
    int? rankTrend,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      gems: gems ?? this.gems,
      totalScore: totalScore ?? this.totalScore,
      quizzesPlayed: quizzesPlayed ?? this.quizzesPlayed,
      rank: rank ?? this.rank,
      rankTrend: rankTrend ?? this.rankTrend,
    );
  }
}
