import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/illustrations.dart';
import '../widgets/sunburst_background.dart';
import '../theme/pill_border.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'main_nav_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final CategoryModel? category;

  const QuizResultScreen({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    final quiz = Provider.of<QuizProvider>(context);
    final accuracy = quiz.totalQuestions > 0
        ? ((quiz.correctAnswersCount / quiz.totalQuestions) * 100).round()
        : 0;

    final isWinning = accuracy >= 70;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const MainNavScreen(initialTab: 0),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF5FC),
        body: SunburstBackground(
          opacity: 0.6,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Header Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isWinning
                              ? const Color(0xFFFEF08A)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isWinning
                                  ? Icons.emoji_events_rounded
                                  : Icons.check_circle_rounded,
                              size: 16,
                              color: const Color(0xFF1E293B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isWinning
                                  ? 'Victory Unlocked!'
                                  : 'Quiz Finished!',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Trophy or Victory Illustration
                      const TrophyIllustration(size: 130),
                      const SizedBox(height: 20),

                      // Headline
                      Text(
                        isWinning ? 'Quiz Champion!' : 'Great Effort!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF131826),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category?.displayName ?? 'General Knowledge Quiz',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Big Gems Earned Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            PillBorder.large(offset: 3.5),
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'YOU EARNED',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const StarIllustration(size: 32),
                                const SizedBox(width: 8),
                                Text(
                                  '+${quiz.gemsEarned}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Saved to Your Profile',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Performance Metrics Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              icon: Iconsax.star,
                              iconColor: const Color(0xFFF59E0B),
                              title: 'Total Score',
                              value: '${quiz.score} pts',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Iconsax.percentage_circle,
                              iconColor: const Color(0xFF10B981),
                              title: 'Accuracy',
                              value: '$accuracy%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              icon: Iconsax.tick_circle,
                              iconColor: const Color(0xFF10B981),
                              title: 'Correct',
                              value:
                                  '${quiz.correctAnswersCount}/${quiz.totalQuestions}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Iconsax.timer_1,
                              iconColor: const Color(0xFF6366F1),
                              title: 'Time Spent',
                              value: '${quiz.totalSecondsElapsed}s',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      // 1. Play Again
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            await quiz.startQuiz(
                              category: category,
                              difficulty: quiz.difficulty,
                              amount: quiz.totalQuestions,
                            );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10141E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Play Again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. View Leaderboard
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            // Refresh leaderboard data
                            Provider.of<LeaderboardProvider>(
                              context,
                              listen: false,
                            ).loadLeaderboard();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MainNavScreen(initialTab: 3),
                              ),
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFF6A9BFA),
                              width: 1.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.ranking, color: Color(0xFF3B82F6)),
                              SizedBox(width: 8),
                              Text(
                                'View Leaderboard',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Home
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MainNavScreen(initialTab: 0),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [PillBorder.userTile(offset: 2.5)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF131826),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
