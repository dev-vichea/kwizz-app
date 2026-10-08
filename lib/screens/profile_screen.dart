import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_result_model.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../utils/avatar_helper.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/illustrations.dart';
import '../theme/pill_border.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<QuizResultModel> _recentHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userProfile?.id;
    if (userId != null) {
      setState(() => _isLoadingHistory = true);
      final history = await _supabaseService.getUserHistory(userId);
      if (mounted) {
        setState(() {
          _recentHistory = history;
          _isLoadingHistory = false;
        });
      }
    }
  }

  void _showAvatarPicker(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your 3D Avatar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF131826),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: AvatarHelper.avatars.keys.map((key) {
                  final isSelected = auth.userProfile?.avatarUrl == key;
                  return GestureDetector(
                    onTap: () {
                      auth.updateAvatar(key);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF6A9BFA),
                                width: 3,
                              )
                            : null,
                      ),
                      child: AvatarCircle(avatarKey: key, size: 58),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.userProfile?.username);
    final titleCtrl = TextEditingController(text: auth.userProfile?.title);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auth.userProfile?.email != null &&
                auth.userProfile!.email!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.alternate_email_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        auth.userProfile!.email!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title (e.g. Student, Scholar)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                auth.updateProfile(
                  username: nameCtrl.text.trim(),
                  title: titleCtrl.text.trim(),
                );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAuth = auth.isAuthenticated;

    if (!isAuth) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF5FC),
        appBar: AppBar(
          title: const Text(
            'My Profile',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFF131826),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 44,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF131826),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'You are currently playing as a guest. Create an account to save your stars, track quiz stats, and compete on the global leaderboard!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const AuthScreen(initialSignUp: true),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10141E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AuthScreen(initialSignUp: false),
                        ),
                      );
                    },
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final user = auth.userProfile ?? auth.defaultProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FC),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF131826),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditProfileDialog(context, auth),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [PillBorder.userTile(offset: 3.0)],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          AvatarCircle(
                            avatarKey: user.avatarUrl,
                            size: 80,
                            onTap: () => _showAvatarPicker(context, auth),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6A9BFA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF131826),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      // if (user.email != null && user.email!.isNotEmpty) ...[
                      //   const SizedBox(height: 8),
                      //   Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const Icon(
                      //         Icons.alternate_email_rounded,
                      //         size: 13,
                      //         color: Color(0xFF64748B),
                      //       ),
                      //       // const SizedBox(width: 4),
                      //       // Text(
                      //       //   user.email!,
                      //       //   style: const TextStyle(
                      //       //     fontSize: 12,
                      //       //     fontWeight: FontWeight.w600,
                      //       //     color: Color(0xFF64748B),
                      //       //   ),
                      //       // ),
                      //     ],
                      //   ),
                      // ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Statistics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        label: 'Total Stars',
                        value: '${user.gems}',
                        leading: const StarIllustration(size: 18),
                        color: const Color(0xFFFEF3C7),
                        textColor: const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        label: 'Quizzes Played',
                        value: '${user.quizzesPlayed}',
                        color: const Color(0xFFE0E7FF),
                        textColor: const Color(0xFF4338CA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        label: 'Total Score',
                        value: '${user.totalScore} pts',
                        color: const Color(0xFFD1FAE5),
                        textColor: const Color(0xFF047857),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatTile(
                        label: 'Global Rank',
                        value: '#${user.rank ?? 7}',
                        color: const Color(0xFFFCE7F3),
                        textColor: const Color(0xFFBE185D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cloud Account Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [PillBorder.userTile(offset: 2.5)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isAuth
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAuth ? Iconsax.cloud_connection : Iconsax.cloud,
                          color: isAuth
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAuth ? 'Cloud Synced' : 'Guest Account Mode',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF131826),
                              ),
                            ),
                            Text(
                              isAuth
                                  ? (user.email != null &&
                                            user.email!.isNotEmpty
                                        ? 'Connected as ${user.email}'
                                        : 'Your scores are synced to the cloud')
                                  : 'Sign in to preserve scores across devices',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (isAuth) {
                            auth.signOut();
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AuthScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          isAuth ? 'Sign Out' : 'Sign In',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isAuth
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Past Quiz History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF131826),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      onPressed: _loadHistory,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_isLoadingHistory)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  )
                else if (_recentHistory.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'No recent quizzes completed yet.\nPlay a quiz to record your results!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentHistory.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _recentHistory[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Iconsax.cup,
                                color: Color(0xFF3B82F6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.category,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF131826),
                                    ),
                                  ),
                                  Text(
                                    '${item.correctAnswers}/${item.totalQuestions} Correct • ${item.difficulty.toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const StarIllustration(size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '+${item.gemsEarned}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    Widget? leading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          PillBorder.medium(offset: 2.5, color: textColor.withOpacity(0.25)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (leading != null) ...[leading, const SizedBox(width: 6)],
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
