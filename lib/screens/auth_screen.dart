import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sunburst_background.dart';

class _BrandSlideItem {
  final String imagePath;
  final String phrase;

  const _BrandSlideItem({required this.imagePath, required this.phrase});
}

class AuthScreen extends StatefulWidget {
  final bool initialSignUp;

  const AuthScreen({super.key, this.initialSignUp = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isSignUp;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  static const _slides = [
    _BrandSlideItem(
      imagePath: 'assets/auth-slide-1.jpg',
      phrase: 'Compete & Climb\nthe Global Leaderboard',
    ),
    _BrandSlideItem(
      imagePath: 'assets/auth-slide-2.jpg',
      phrase: 'Master Thousands\nof Trivia Topics',
    ),
    _BrandSlideItem(
      imagePath: 'assets/auth-slide-3.jpg',
      phrase: 'Unlock 3D Avatars\n& Custom Rank Titles',
    ),
  ];

  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    bool success = false;
    if (_isSignUp) {
      success = await auth.signUp(email, password, username);
    } else {
      success = await auth.signIn(email, password);
    }

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    }
  }

  void _showForgotPasswordDialog(BuildContext context, AuthProvider auth) {
    final resetEmailCtrl =
        TextEditingController(text: _emailController.text.trim());
    bool isSending = false;
    String? resetError;
    String? resetSuccess;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF131826),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your registered email address. We will send you a password recovery link.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: _inputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                  ),
                  if (resetError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFDC2626),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              resetError!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (resetSuccess != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFF059669),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              resetSuccess!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final targetEmail = resetEmailCtrl.text.trim();
                          if (targetEmail.isEmpty || !targetEmail.contains('@')) {
                            setDialogState(() {
                              resetError = 'Please enter a valid email address';
                              resetSuccess = null;
                            });
                            return;
                          }

                          setDialogState(() {
                            isSending = true;
                            resetError = null;
                            resetSuccess = null;
                          });

                          final ok = await auth.resetPassword(targetEmail);
                          if (ctx.mounted) {
                            setDialogState(() {
                              isSending = false;
                              if (ok) {
                                resetSuccess =
                                    'Reset link sent! Please check your inbox.';
                                resetError = null;
                              } else {
                                resetError = auth.errorMessage ??
                                    'Failed to send reset link. Try again.';
                                resetSuccess = null;
                              }
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10141E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send Link',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          _isSignUp ? 'Create Account' : 'Sign In',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF131826),
          ),
        ),
      ),
      body: SunburstBackground(
        opacity: 0.45,
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;

                if (isWide) {
                  final cardWidth = (constraints.maxWidth - 48).clamp(
                    0.0,
                    880.0,
                  );
                  final leftWidth = cardWidth * (5 / 11);

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 880),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              // Form defines the height of the card
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: leftWidth),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(36),
                                      child: _buildForm(auth),
                                    ),
                                  ),
                                ],
                              ),
                              // Left Branding Panel fills left side from top to bottom
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                width: leftWidth,
                                child: _buildBrandingPanel(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Mobile Layout (< 768px)
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        children: [
                          _buildMobileHeader(),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: _buildForm(auth),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingPanel() {
    return LayoutBuilder(
      builder: (context, panelConstraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-bleed CarouselSlider filling the panel
            CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: panelConstraints.maxHeight,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 600),
                autoPlayCurve: Curves.easeInOutCubic,
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentSlide = index;
                  });
                },
              ),
              items: _slides.map((slide) {
                return Image.asset(
                  slide.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              }).toList(),
            ),

            // 2. Elegant dark vignette gradient overlay for contrast
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F172A).withOpacity(0.40),
                      Colors.transparent,
                      const Color(0xFF0F172A).withOpacity(0.35),
                      const Color(0xFF0A0E1A).withOpacity(0.92),
                    ],
                    stops: const [0.0, 0.25, 0.58, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Logo pinned on the top left
            Positioned(top: 28, left: 28, child: _buildBrandingLogo()),

            // 4. Phrase (fading in place above the indicator) & Indicator at bottom center
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      _slides[_currentSlide].phrase,
                      key: ValueKey<int>(_currentSlide),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildSlideIndicator(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrandingLogo() {
    return Image.asset(
      'assets/favicon/android-chrome-192x192.png',
      width: 44,
      height: 44,
      fit: BoxFit.contain,
    );
  }

  Widget _buildSlideIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final isActive = _currentSlide == index;
        return GestureDetector(
          onTap: () {
            _carouselController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/favicon/android-chrome-192x192.png',
          width: 52,
          height: 52,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        Text(
          _isSignUp
              ? 'Join the Global Quiz Arena'
              : 'Welcome back, trivia master',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isSignUp) {
                  setState(() {
                    _isSignUp = false;
                    _formKey.currentState?.reset();
                  });
                  Provider.of<AuthProvider>(context, listen: false).clearError();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isSignUp
                      ? const Color(0xFF10141E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isSignUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: !_isSignUp
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isSignUp) {
                  setState(() {
                    _isSignUp = true;
                    _formKey.currentState?.reset();
                  });
                  Provider.of<AuthProvider>(context, listen: false).clearError();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isSignUp
                      ? const Color(0xFF10141E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isSignUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _isSignUp ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AuthProvider auth) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Segmented Switcher
            _buildSegmentedSwitcher(),
            const SizedBox(height: 24),

            // Title
            Text(
              _isSignUp ? 'Create Account' : 'Sign In',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF131826),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isSignUp
                  ? 'Enter your details below to start playing!'
                  : 'Enter your credentials to access your account.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            // Error message if any
            if (auth.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Username (sign up only)
            if (_isSignUp) ...[
              TextFormField(
                controller: _usernameController,
                autocorrect: false,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter a username';
                  }
                  if (val.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icons.alternate_email_rounded,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your email';
                }
                final trimmed = val.trim();
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(trimmed)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autocorrect: false,
              autofillHints: _isSignUp
                  ? const [AutofillHints.newPassword]
                  : const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: _inputDecoration(
                labelText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (val) {
                if (val == null || val.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            if (!_isSignUp) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordDialog(context, auth),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ] else
              const SizedBox(height: 24),

            // Submit Button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
              ),
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10141E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUp ? 'Create Account' : 'Sign In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Continue as Guest link
            Center(
              child: TextButton.icon(
                onPressed: () {
                  auth.continueAsGuest();
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(
                  Icons.explore_outlined,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                label: const Text(
                  'Continue as Guest Explorer',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
      prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF64748B)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2.0),
      ),
    );
  }
}
