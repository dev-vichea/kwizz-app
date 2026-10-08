import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/custom_bottom_nav.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'quiz_explore_screen.dart';
import 'quiz_play_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialTab;

  const MainNavScreen({super.key, this.initialTab = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      // "Play" tab: Quick Instant Match
      _launchQuickMatch();
      return;
    }
    if (index == 4) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isAuthenticated) {
        // Guest account: push to create account
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AuthScreen(initialSignUp: false),
          ),
        ).then((_) {
          if (mounted && Provider.of<AuthProvider>(context, listen: false).isAuthenticated) {
            setState(() {
              _currentIndex = 4;
            });
          }
        });
        return;
      }
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _launchQuickMatch() async {
    final quiz = Provider.of<QuizProvider>(context, listen: false);
    await quiz.startQuiz(amount: 10, difficulty: 'medium');
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const QuizExploreScreen(),
      const SizedBox(), // Play tab triggers quick quiz modal
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
