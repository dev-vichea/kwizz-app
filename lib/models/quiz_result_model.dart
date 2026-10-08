class QuizResultModel {
  final String id;
  final String? userId;
  final String username;
  final String category;
  final String difficulty;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int gemsEarned;
  final DateTime createdAt;

  QuizResultModel({
    required this.id,
    this.userId,
    required this.username,
    required this.category,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.gemsEarned,
    required this.createdAt,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      username: json['username'] ?? 'Player',
      category: json['category'] ?? 'General',
      difficulty: json['difficulty'] ?? 'easy',
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'] ?? 10,
      correctAnswers: json['correct_answers'] ?? 0,
      gemsEarned: json['gems_earned'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': (userId != null && userId != 'guest' && userId!.isNotEmpty)
          ? userId
          : null,
      'username': username,
      'category': category,
      'difficulty': difficulty,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'gems_earned': gemsEarned,
    };
  }

  double get accuracy => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
}
