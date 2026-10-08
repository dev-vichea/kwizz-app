import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../services/opentdb_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

class QuizProvider extends ChangeNotifier {
  final OpenTdbService _openTdbService = OpenTdbService();
  final SupabaseService _supabaseService = SupabaseService();

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isAnswerChecked = false;
  int? _selectedAnswerIndex;
  
  int _score = 0;
  int _correctAnswersCount = 0;
  int _gemsEarned = 0;
  int _streak = 0;
  int _maxStreak = 0;
  
  // Timer
  static const int questionTimeLimit = 20; // seconds per question
  int _remainingSeconds = questionTimeLimit;
  Timer? _timer;
  int _totalSecondsElapsed = 0;
  
  // Lifelines
  bool _fiftyFiftyUsed = false;
  bool _extraTimeUsed = false;
  bool _skipUsed = false;
  List<int> _disabledAnswerIndices = [];

  // Active quiz metadata
  CategoryModel? _activeCategory;
  String _difficulty = 'medium';
  bool _isQuizCompleted = false;

  // Getters
  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  bool get isLoading => _isLoading;
  bool get isAnswerChecked => _isAnswerChecked;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  int get score => _score;
  int get correctAnswersCount => _correctAnswersCount;
  int get gemsEarned => _gemsEarned;
  int get streak => _streak;
  int get remainingSeconds => _remainingSeconds;
  int get totalSecondsElapsed => _totalSecondsElapsed;
  bool get fiftyFiftyUsed => _fiftyFiftyUsed;
  bool get extraTimeUsed => _extraTimeUsed;
  bool get skipUsed => _skipUsed;
  List<int> get disabledAnswerIndices => _disabledAnswerIndices;
  CategoryModel? get activeCategory => _activeCategory;
  String get difficulty => _difficulty;
  bool get isQuizCompleted => _isQuizCompleted;

  QuestionModel? get currentQuestion =>
      (_questions.isNotEmpty && _currentIndex < _questions.length)
          ? _questions[_currentIndex]
          : null;

  double get progress =>
      totalQuestions > 0 ? (_currentIndex + 1) / totalQuestions : 0.0;

  Future<void> startQuiz({
    CategoryModel? category,
    String difficulty = 'medium',
    int amount = 10,
    String type = 'multiple',
  }) async {
    _isLoading = true;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _correctAnswersCount = 0;
    _gemsEarned = 0;
    _streak = 0;
    _maxStreak = 0;
    _totalSecondsElapsed = 0;
    _fiftyFiftyUsed = false;
    _extraTimeUsed = false;
    _skipUsed = false;
    _disabledAnswerIndices = [];
    _isQuizCompleted = false;
    _isAnswerChecked = false;
    _selectedAnswerIndex = null;
    _activeCategory = category;
    _difficulty = difficulty;
    notifyListeners();

    try {
      _questions = await _openTdbService.fetchQuestions(
        amount: amount,
        categoryId: category?.id,
        difficulty: difficulty,
        type: type,
      );
    } catch (_) {
      _questions = [];
    }

    _isLoading = false;
    if (_questions.isNotEmpty) {
      _startTimer();
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = questionTimeLimit;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _totalSecondsElapsed++;
        notifyListeners();
      } else {
        _timer?.cancel();
        // Time ran out: auto submit wrong answer
        autoSubmitTimeOut();
      }
    });
  }

  void selectAnswer(int index) {
    if (_isAnswerChecked || _disabledAnswerIndices.contains(index)) return;
    _selectedAnswerIndex = index;
    notifyListeners();
  }

  void confirmAnswer() {
    if (_isAnswerChecked || _selectedAnswerIndex == null || currentQuestion == null) {
      return;
    }

    _timer?.cancel();
    _isAnswerChecked = true;
    currentQuestion!.selectedAnswerIndex = _selectedAnswerIndex;
    currentQuestion!.isAnswered = true;

    final bool isCorrect = currentQuestion!.isCorrect;

    if (isCorrect) {
      _correctAnswersCount++;
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;

      // Base 100 points + time bonus up to 50 + streak bonus
      final timeBonus = (_remainingSeconds * 2.5).round();
      final streakBonus = (_streak * 10);
      final questionScore = 100 + timeBonus + streakBonus;
      _score += questionScore;

      // Earn 10 gems per correct answer
      _gemsEarned += 10;
    } else {
      _streak = 0;
    }

    notifyListeners();
  }

  void autoSubmitTimeOut() {
    if (_isAnswerChecked || currentQuestion == null) return;
    _isAnswerChecked = true;
    _selectedAnswerIndex = -1; // No answer chosen
    currentQuestion!.selectedAnswerIndex = -1;
    currentQuestion!.isAnswered = true;
    _streak = 0;
    notifyListeners();
  }

  void nextQuestion(AuthProvider authProvider) {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _isAnswerChecked = false;
      _selectedAnswerIndex = null;
      _disabledAnswerIndices = [];
      _startTimer();
      notifyListeners();
    } else {
      // Quiz completed!
      _finishQuiz(authProvider);
    }
  }

  // Lifelines
  void useFiftyFifty() {
    if (_fiftyFiftyUsed || _isAnswerChecked || currentQuestion == null) return;
    _fiftyFiftyUsed = true;

    final correctIndex = currentQuestion!.correctAnswerIndex;
    final List<int> wrongIndices = [];
    for (int i = 0; i < currentQuestion!.allAnswers.length; i++) {
      if (i != correctIndex) {
        wrongIndices.add(i);
      }
    }
    wrongIndices.shuffle();
    // Disable up to 2 wrong answers
    _disabledAnswerIndices = wrongIndices.take(2).toList();
    notifyListeners();
  }

  void useExtraTime() {
    if (_extraTimeUsed || _isAnswerChecked) return;
    _extraTimeUsed = true;
    _remainingSeconds += 15;
    notifyListeners();
  }

  void useSkipQuestion(AuthProvider authProvider) {
    if (_skipUsed || _isAnswerChecked) return;
    _skipUsed = true;
    _timer?.cancel();
    nextQuestion(authProvider);
  }

  Future<void> _finishQuiz(AuthProvider authProvider) async {
    _timer?.cancel();
    _isQuizCompleted = true;

    // Bonus 20 gems for completing the quiz
    _gemsEarned += 20;

    // Perfect score bonus
    if (_correctAnswersCount == _questions.length && _questions.isNotEmpty) {
      _gemsEarned += 50;
      _score += 500;
    }

    notifyListeners();

    // Persist to user profile
    await authProvider.addGemsAndScore(
      earnedGems: _gemsEarned,
      earnedScore: _score,
    );

    // Persist result to Supabase
    final result = QuizResultModel(
      id: '',
      userId: authProvider.userProfile?.id,
      username: authProvider.userProfile?.username ?? 'Emily Rose',
      category: _activeCategory?.displayName ?? 'General Knowledge',
      difficulty: _difficulty,
      score: _score,
      totalQuestions: _questions.length,
      correctAnswers: _correctAnswersCount,
      gemsEarned: _gemsEarned,
      createdAt: DateTime.now(),
    );

    await _supabaseService.saveQuizResult(result);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
