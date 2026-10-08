import 'package:flutter_test/flutter_test.dart';
import 'package:kwizz/models/question_model.dart';
import 'package:kwizz/models/category_model.dart';
import 'package:kwizz/models/user_profile_model.dart';
import 'package:kwizz/models/user_model.dart';
import 'package:kwizz/models/quiz_result_model.dart';
import 'package:kwizz/services/opentdb_service.dart';

void main() {
  group('OpenTDB Question Model Tests', () {
    test('Decodes HTML entities and shuffles choices correctly', () {
      final json = {
        'category': 'Science: Computers',
        'type': 'multiple',
        'difficulty': 'easy',
        'question': 'What does &quot;HTML&quot; stand for?',
        'correct_answer': 'HyperText &amp; Markup Language',
        'incorrect_answers': [
          'HighText &#039;Machine&#039; Language',
          'Hyperlink and Text',
          'Home Tool'
        ]
      };

      final question = QuestionModel.fromOpenTdbJson(json);

      expect(question.question, 'What does "HTML" stand for?');
      expect(question.correctAnswer, 'HyperText & Markup Language');
      expect(question.incorrectAnswers[0], "HighText 'Machine' Language");
      expect(question.allAnswers.length, 4);
      expect(question.allAnswers.contains('HyperText & Markup Language'), isTrue);

      // Verify correct answer index
      final correctIndex = question.correctAnswerIndex;
      expect(correctIndex, isNonNegative);
      expect(question.allAnswers[correctIndex], question.correctAnswer);

      // Verify answer check logic
      question.selectedAnswerIndex = correctIndex;
      expect(question.isCorrect, isTrue);

      // Select wrong answer
      final wrongIndex = (correctIndex + 1) % 4;
      question.selectedAnswerIndex = wrongIndex;
      expect(question.isCorrect, isFalse);
    });

    test('Curated fallback questions provide playable trivia', () async {
      final service = OpenTdbService();
      // Test offline fallback logic
      final questions = await service.fetchQuestions(
        amount: 5,
        categoryId: 18, // Tech
      );

      expect(questions.isNotEmpty, isTrue);
      expect(questions.length, 5);
      expect(questions.first.allAnswers.length, 4);
      expect(questions.first.question.isNotEmpty, isTrue);
    });
  });

  group('Category & User Profile Models', () {
    test('Default categories contains Tech and Science', () {
      final tech = CategoryModel.defaultCategories.firstWhere((c) => c.id == 18);
      expect(tech.displayName, 'Future of Tech');
      expect(tech.tag, 'Tech');
      expect(tech.isPopular, isTrue);
    });

    test('UserProfileModel JSON serialization & copyWith', () {
      final profile = UserProfileModel(
        id: 'user-123',
        email: 'emily@example.com',
        username: 'Emily Rose',
        avatarUrl: 'avatar_7',
        title: 'Student',
        gems: 30,
        totalScore: 250,
        quizzesPlayed: 4,
      );

      final json = profile.toJson();
      expect(json['username'], 'Emily Rose');
      expect(json['email'], 'emily@example.com');
      expect(json['gems'], 30);

      // toDbJson must exclude email to avoid Supabase profiles table schema mismatch
      final dbJson = profile.toDbJson();
      expect(dbJson.containsKey('email'), isFalse);
      expect(dbJson['username'], 'Emily Rose');
      expect(dbJson['id'], 'user-123');

      final updated = profile.copyWith(
        email: 'emily.new@example.com',
        gems: 50,
        quizzesPlayed: 5,
      );
      expect(updated.email, 'emily.new@example.com');
      expect(updated.gems, 50);
      expect(updated.quizzesPlayed, 5);
      expect(updated.username, 'Emily Rose');
    });

    test('QuizResultModel sanitizes guest user_id to null for Postgres UUID column', () {
      final guestResult = QuizResultModel(
        id: 'res-1',
        userId: 'guest',
        username: 'Guest Player',
        category: 'Tech',
        difficulty: 'easy',
        score: 100,
        totalQuestions: 10,
        correctAnswers: 10,
        gemsEarned: 10,
        createdAt: DateTime.now(),
      );

      final guestJson = guestResult.toJson();
      expect(guestJson['user_id'], isNull);

      final authResult = QuizResultModel(
        id: 'res-2',
        userId: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
        username: 'Emily Rose',
        category: 'Tech',
        difficulty: 'hard',
        score: 100,
        totalQuestions: 10,
        correctAnswers: 10,
        gemsEarned: 30,
        createdAt: DateTime.now(),
      );

      final authJson = authResult.toJson();
      expect(authJson['user_id'], 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6');
    });

    test('UserModel JSON serialization & copyWith', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'user-xyz',
        email: 'alex@example.com',
        createdAt: now,
        updatedAt: now,
      );

      final json = user.toJson();
      expect(json['id'], 'user-xyz');
      expect(json['email'], 'alex@example.com');

      final fromJson = UserModel.fromJson(json);
      expect(fromJson.id, 'user-xyz');
      expect(fromJson.email, 'alex@example.com');

      final copy = user.copyWith(email: 'alex.updated@example.com');
      expect(copy.email, 'alex.updated@example.com');
      expect(copy.id, 'user-xyz');
    });
  });
}
