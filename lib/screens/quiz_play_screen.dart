import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/pill_border.dart';
import '../widgets/illustrations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatelessWidget {
  final CategoryModel? category;

  const QuizPlayScreen({super.key, this.category});

  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text(
          'Your progress for this quiz session will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Playing'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Quit Quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = Provider.of<QuizProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // If quiz is completed, navigate to result
    if (quiz.isQuizCompleted && !quiz.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(category: category),
          ),
        );
      });
    }

    if (quiz.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF5FC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 18),
              Text(
                'Fetching Trivia Questions...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF131826),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Preparing your questions...',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    if (quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.info_circle, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'No questions available for this selection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Arena'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = quiz.currentQuestion;
    if (question == null) return const Scaffold();

    final isAnswerChecked = quiz.isAnswerChecked;
    final timerSeconds = quiz.remainingSeconds;
    final isTimerWarning = timerSeconds <= 5;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmQuit(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF5FC),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 24),
            onPressed: () => _confirmQuit(context),
          ),
          centerTitle: true,
          title: Text(
            category?.displayName ?? 'Quick Trivia',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF131826),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2EDFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const StarIllustration(size: 15),
                  const SizedBox(width: 4),
                  Text(
                    '+${quiz.gemsEarned}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF131826),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  // Progress Bar & Question Counter & Timer
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${quiz.currentIndex + 1} of ${quiz.totalQuestions}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            // Difficulty Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                question.difficulty.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Linear Animated Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: quiz.progress,
                            minHeight: 8,
                            backgroundColor: const Color(
                              0xFFCBD5E1,
                            ).withOpacity(0.4),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6A9BFA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timer & Streak Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Timer pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isTimerWarning
                                ? const Color(0xFFFEE2E2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isTimerWarning
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.timer_1,
                                size: 16,
                                color: isTimerWarning
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$timerSeconds s',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isTimerWarning
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF131826),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Streak Pill
                        if (quiz.streak > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF97316),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 15,
                                  color: Color(0xFFEA580C),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${quiz.streak} Streak',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFC2410C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Main Quiz Body (Question Card + Answers)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          // Question Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [PillBorder.userTile(offset: 3.0)],
                            ),
                            child: Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF131826),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Answer Choices
                          ...List.generate(question.allAnswers.length, (index) {
                            final answer = question.allAnswers[index];
                            final isSelected =
                                quiz.selectedAnswerIndex == index;
                            final isDisabled = quiz.disabledAnswerIndices
                                .contains(index);
                            final isCorrect =
                                question.correctAnswerIndex == index;

                            Color cardBg = Colors.white;
                            Color borderColor = const Color(0xFFE2E8F0);
                            Color textColor = const Color(0xFF131826);
                            Color circleBg = const Color(0xFFF1F5F9);
                            Color circleTextColor = const Color(0xFF475569);
                            Widget? trailingIcon;

                            if (isDisabled) {
                              cardBg = const Color(0xFFF8FAFC);
                              textColor = const Color(0xFF94A3B8);
                            } else if (isAnswerChecked) {
                              if (isCorrect) {
                                cardBg = const Color(0xFFD1FAE5);
                                borderColor = const Color(0xFF10B981);
                                circleBg = const Color(0xFF10B981);
                                circleTextColor = Colors.white;
                                trailingIcon = const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                );
                              } else if (isSelected && !isCorrect) {
                                cardBg = const Color(0xFFFEE2E2);
                                borderColor = const Color(0xFFEF4444);
                                circleBg = const Color(0xFFEF4444);
                                circleTextColor = Colors.white;
                                trailingIcon = const Icon(
                                  Icons.cancel_rounded,
                                  color: Color(0xFFEF4444),
                                );
                              }
                            } else if (isSelected) {
                              cardBg = const Color(0xFFEBF4FE);
                              borderColor = const Color(0xFF6A9BFA);
                              circleBg = const Color(0xFF6A9BFA);
                              circleTextColor = Colors.white;
                            }

                            final optionLetters = ['A', 'B', 'C', 'D'];
                            final letter = index < optionLetters.length
                                ? optionLetters[index]
                                : '${index + 1}';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: isDisabled || isAnswerChecked
                                    ? null
                                    : () => quiz.selectAnswer(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.8,
                                    ),
                                    boxShadow: [
                                      PillBorder.medium(
                                        offset: 2.5,
                                        color: isAnswerChecked
                                            ? (isCorrect
                                                  ? const Color(0xFF059669)
                                                  : (isSelected
                                                        ? const Color(
                                                            0xFFDC2626,
                                                          )
                                                        : PillBorder.grey))
                                            : (isSelected
                                                  ? const Color(0xFF2563EB)
                                                  : PillBorder.grey),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: circleBg,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            letter,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: circleTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          answer,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      ?trailingIcon,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 12),

                          // Lifelines Row (50/50, +15s, Skip)
                          if (!isAnswerChecked)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildLifelineButton(
                                  icon: Iconsax.diagram,
                                  label: '50 : 50',
                                  isUsed: quiz.fiftyFiftyUsed,
                                  onTap: quiz.useFiftyFifty,
                                ),
                                _buildLifelineButton(
                                  icon: Iconsax.timer_start,
                                  label: '+15s Time',
                                  isUsed: quiz.extraTimeUsed,
                                  onTap: quiz.useExtraTime,
                                ),
                                _buildLifelineButton(
                                  icon: Icons.skip_next_rounded,
                                  label: 'Skip',
                                  isUsed: quiz.skipUsed,
                                  onTap: () => quiz.useSkipQuestion(auth),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isAnswerChecked
                            ? () => quiz.nextQuestion(auth)
                            : (quiz.selectedAnswerIndex != null
                                  ? quiz.confirmAnswer
                                  : null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAnswerChecked
                              ? const Color(0xFF6A9BFA)
                              : const Color(0xFF10141E),
                          disabledBackgroundColor: const Color(0xFFCBD5E1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          isAnswerChecked
                              ? (quiz.currentIndex == quiz.totalQuestions - 1
                                    ? 'See Results'
                                    : 'Next Question →')
                              : 'Confirm Answer',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLifelineButton({
    required IconData icon,
    required String label,
    required bool isUsed,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isUsed ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isUsed ? const Color(0xFFF1F5F9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUsed ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isUsed ? const Color(0xFF94A3B8) : const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isUsed
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
