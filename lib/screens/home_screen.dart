import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../services/storage_service.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/illustrations.dart';
import '../widgets/sunburst_background.dart';
import '../theme/pill_border.dart';
import 'quiz_play_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  Set<int> _favoriteIds = {18};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final favs = await _storageService.getFavoriteCategoryIds();
    if (mounted) {
      setState(() {
        _favoriteIds = favs.toSet();
      });
    }
  }

  void _toggleFavorite(int categoryId) async {
    await _storageService.toggleFavoriteCategory(categoryId);
    setState(() {
      if (_favoriteIds.contains(categoryId)) {
        _favoriteIds.remove(categoryId);
      } else {
        _favoriteIds.add(categoryId);
      }
    });
  }

  void _launchQuiz(
    CategoryModel category, {
    String difficulty = 'medium',
  }) async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.startQuiz(
      category: category,
      difficulty: difficulty,
      amount: 10,
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizPlayScreen(category: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userProfile ?? auth.defaultProfile;
    final popularCategories = CategoryModel.defaultCategories;
    final techCategory = popularCategories.firstWhere((c) => c.id == 18);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FC),
      body: SunburstBackground(
        opacity: 0.6,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Top Header: User Profile & Gems Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Avatar & Name + Student tag
                        Row(
                          children: [
                            AvatarCircle(
                              avatarKey: user.avatarUrl,
                              size: 52,
                              onTap: () => widget.onNavigateTab?.call(4),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF131826),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF64748B,
                                      ).withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    user.title,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Stars Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EDFB),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [PillBorder.tiny(offset: 1.5)],
                          ),
                          child: Row(
                            children: [
                              const StarIllustration(size: 22),
                              const SizedBox(width: 8),
                              Text(
                                '${user.gems}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF131826),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Responsive Banners: Side-by-side on wide screens (>= 640px), stacked on mobile
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 640) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildChampionBanner(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: _buildUpgradeProBanner(),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: [
                            _buildChampionBanner(),
                            const SizedBox(height: 16),
                            _buildUpgradeProBanner(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section Title: Popular Game & See All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Popular Game',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF131826),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.onNavigateTab?.call(1),
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Featured Card: Future of Tech
                    _buildTechFeaturedCard(techCategory),
                    const SizedBox(height: 24),

                    // More Popular Categories Carousel / Responsive Grid
                    const Text(
                      'Explore More Quizzes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF131826),
                      ),
                    ),
                    const SizedBox(height: 12),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 640) {
                          final crossAxisCount = constraints.maxWidth >= 840
                              ? 4
                              : 3;
                          final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 14) / crossAxisCount;
                          final itemHeight = itemWidth / 1.15;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              for (int i = 1; i < popularCategories.length; i++)
                                SizedBox(
                                  width: itemWidth,
                                  height: itemHeight,
                                  child: _buildMiniCategoryCard(
                                    popularCategories[i],
                                    isGrid: true,
                                  ),
                                ),
                            ],
                          );
                        }
                        return SizedBox(
                          height: 176,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.only(bottom: 6),
                            itemCount: popularCategories.length - 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final category = popularCategories[index + 1];
                              return _buildMiniCategoryCard(category);
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80), // padding for bottom nav
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChampionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 14, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFC7E2FE),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Solid 3D pill border ONLY at the bottom of the card
          PillBorder.large(offset: 3),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rise Up Quiz',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  height: 1.15,
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomLeft,
                children: [
                  Positioned(
                    left: -2,
                    right: -2,
                    bottom: 1,
                    height: 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF08A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text(
                    'Champion',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Climb ranks, sharpen minds,\nbecome quiz champion.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                  height: 1.35,
                ),
              ),
            ],
          ),
          const Positioned(
            right: -2,
            top: -8,
            bottom: -8,
            child: TrophyIllustration(size: 102),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeProBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4E7FD),
        borderRadius: BorderRadius.circular(30), // Pill shape
        boxShadow: [
          // Solid 3D pill border ONLY at the bottom of the card
          PillBorder.medium(offset: 2),
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          children: [
            // Crown illustration
            const CrownIllustration(size: 42),
            const SizedBox(width: 14),

            // Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Upgrade pro',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF131826),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Congrats! Access Granted',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Circular Arrow Button
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Pro Access is Active! 2x Stars Bonus Unlocked!',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF131826),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_outward_rounded,
                  size: 20,
                  color: Color(0xFF131826),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechFeaturedCard(CategoryModel category) {
    final isFav = _favoriteIds.contains(category.id);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: category.gradientColors,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          PillBorder.large(offset: 4),
          BoxShadow(
            color: category.gradientColors.last.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // 3D VR Tech Girl character graphic (half body, no legs)
            Positioned(
              right: -30,
              top: -10,
              bottom: -230,
              width: 330,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/tech-girl.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // Dark overlay for text legibility
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.0, 0.55, 0.85, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.70),
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Tag: Tech & Favorite Heart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.tag,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavorite(category.id),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFav
                                ? const Color(0xFFEF4444)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title: Future of Tech
                  Text(
                    category.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.92),
                        height: 1.35,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Circular action button
                  InkWell(
                    onTap: () => _launchQuiz(category),
                    borderRadius: BorderRadius.circular(26),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        color: Color(0xFF10141E),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCategoryCard(CategoryModel category, {bool isGrid = false}) {
    final hasImage = category.imageAsset != null;

    return GestureDetector(
      onTap: () => _launchQuiz(category),
      child: Container(
        width: isGrid ? null : 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            PillBorder.medium(offset: 2.5),
            BoxShadow(
              color: category.gradientColors.last.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background (Image or Gradient)
              if (hasImage)
                Positioned.fill(
                  child: Image.asset(category.imageAsset!, fit: BoxFit.cover),
                ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: hasImage ? const [0.45, 0.75, 1.0] : null,
                      colors: hasImage
                          ? [
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                              Colors.black.withOpacity(0.85),
                            ]
                          : category.gradientColors,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category.tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '10 Questions',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
