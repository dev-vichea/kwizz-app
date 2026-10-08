import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../services/storage_service.dart';
import '../widgets/illustrations.dart';
import 'main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final StorageService _storageService = StorageService();
  int _activePageIndex = 1; // Middle dot active as in screenshot

  void _finishOnboarding() async {
    await _storageService.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEAF9), // Soft sky blue matching screenshot
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar: Logo & Skip Button
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo with mini trophy
                  Row(
                    children: [
                      const Text(
                        'Kwizz',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF131826),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.translate(
                        offset: const Offset(0, -2),
                        child: const TrophyIllustration(size: 26),
                      ),
                    ],
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1E293B),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

            // Graphic Illustration Area
            Expanded(
              flex: 12,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 390,
                    height: 330,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                  // Soft circular background rings
                  Positioned(
                    top: 10,
                    child: Container(
                      width: 290,
                      height: 290,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ),

                  // Yellow tilted background blob
                  Positioned(
                    top: 50,
                    right: 40,
                    child: Transform.rotate(
                      angle: -0.15,
                      child: Container(
                        width: 220,
                        height: 190,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC833),
                          borderRadius: BorderRadius.circular(48),
                        ),
                      ),
                    ),
                  ),

                  // Speech Bubble (Teal "Smart Play Wins")
                  Positioned(
                    top: 60,
                    left: 28,
                    child: Container(
                      width: 230,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43C7C7),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(
                                  Iconsax.message_question,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Smart',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF10192A),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Play Wins',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10192A),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Learn fast, think smart,\nwin every challenge.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F3E3E),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Golden Trophy with ribbons (Top Right of graphic)
                  const Positioned(
                    top: 35,
                    right: 42,
                    child: TrophyIllustration(size: 110),
                  ),

                  // Book with glowing lightbulb (Bottom of graphic)
                  const Positioned(
                    bottom: 25,
                    child: BookLightbulbIllustration(size: 96),
                  ),
                ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Curved White Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(44),
                  topRight: Radius.circular(44),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Headline
                  const Text(
                    'Play Smart Quiz\nEvery Day',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF131826),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Boost knowledge daily, win challenges,\nbecome smarter every day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B788E),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicatorDot(0),
                      const SizedBox(width: 6),
                      _buildIndicatorDot(1),
                      const SizedBox(width: 6),
                      _buildIndicatorDot(2),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Button Bar
                  Row(
                    children: [
                      // Back / Left circular button
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (_activePageIndex > 0) _activePageIndex--;
                          });
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF131826),
                              width: 2.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 24,
                            color: Color(0xFF131826),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Get Started capsule button
                      Expanded(
                        child: InkWell(
                          onTap: _finishOnboarding,
                          borderRadius: BorderRadius.circular(34),
                          child: Container(
                            height: 58,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10141E),
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Lightbulb badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF8BB7FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Iconsax.lamp_on,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 14),
                                  child: Text(
                                    '>>>',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6B788E),
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorDot(int index) {
    final bool isActive = _activePageIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 24 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF5B92F7) : const Color(0xFF10141E),
        borderRadius: BorderRadius.circular(4),
        border: isActive
            ? Border.all(color: const Color(0xFF10141E), width: 1.2)
            : null,
      ),
    );
  }
}
