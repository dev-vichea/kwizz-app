import 'dart:math';
import 'package:html_unescape/html_unescape.dart';

class QuestionModel {
  final String category;
  final String type;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers;
  int? selectedAnswerIndex;
  bool isAnswered;

  QuestionModel({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.allAnswers,
    this.selectedAnswerIndex,
    this.isAnswered = false,
  });

  factory QuestionModel.fromOpenTdbJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();
    final question = unescape.convert(json['question'] ?? '');
    final correctAnswer = unescape.convert(json['correct_answer'] ?? '');
    final List<dynamic> rawIncorrect = json['incorrect_answers'] ?? [];
    final incorrectAnswers = rawIncorrect
        .map((ans) => unescape.convert(ans.toString()))
        .toList();

    final allAnswers = List<String>.from(incorrectAnswers)..add(correctAnswer);
    // Shuffle answers so correct answer is not always last
    allAnswers.shuffle(Random());

    return QuestionModel(
      category: unescape.convert(json['category'] ?? 'General'),
      type: json['type'] ?? 'multiple',
      difficulty: json['difficulty'] ?? 'easy',
      question: question,
      correctAnswer: correctAnswer,
      incorrectAnswers: incorrectAnswers,
      allAnswers: allAnswers,
    );
  }

  bool get isCorrect {
    if (selectedAnswerIndex == null ||
        selectedAnswerIndex! < 0 ||
        selectedAnswerIndex! >= allAnswers.length) {
      return false;
    }
    return allAnswers[selectedAnswerIndex!] == correctAnswer;
  }

  int get correctAnswerIndex {
    return allAnswers.indexOf(correctAnswer);
  }
}
