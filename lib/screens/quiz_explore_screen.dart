import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/quiz_provider.dart';
import '../theme/pill_border.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'quiz_play_screen.dart';

class QuizExploreScreen extends StatefulWidget {
  const QuizExploreScreen({super.key});

  @override
  State<QuizExploreScreen> createState() => _QuizExploreScreenState();
}

class _QuizExploreScreenState extends State<QuizExploreScreen> {
  String _selectedDifficulty = 'medium';
  int _questionCount = 10;
  final String _questionType = 'multiple';
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = CategoryModel.defaultCategories.first;
  }

  void _startQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.startQuiz(
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      amount: _questionCount,
      type: _questionType,
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizPlayScreen(category: _selectedCategory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryModel.defaultCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FC),
      appBar: AppBar(
        title: const Text(
          'Quiz Arena',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF131826),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;

                if (isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildQuickMatchCard(),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Category Selection
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Category',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF131826),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildCategoriesGrid(categories),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Right Column: Difficulty, Question Count & Launch
                          Expanded(flex: 2, child: _buildQuizControls()),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  );
                }

                // Mobile Layout (< 768px)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildQuickMatchCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF131826),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoriesGrid(categories),
                    const SizedBox(height: 24),
                    _buildQuizControls(),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMatchCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          PillBorder.large(offset: 3.5),
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'Quick Play Match',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Instant 10 random questions to test your knowledge!',
                  style: TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _selectedCategory = null; // Random
              _startQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1D4ED8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Play Now',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List<CategoryModel> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount;
        if (constraints.maxWidth >= 520) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        final itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
        final itemHeight = itemWidth / 1.25;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int index = 0; index < categories.length; index++)
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _buildCategoryItem(categories[index]),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(CategoryModel cat) {
    final isSelected = _selectedCategory?.id == cat.id;
    final hasImage = cat.imageAsset != null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = cat;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: [
            PillBorder.medium(
              offset: 2.5,
              color: isSelected ? const Color(0xFF1D4ED8) : PillBorder.grey,
            ),
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Background Image or Gradient/Color
              if (hasImage)
                Positioned.fill(
                  child: Image.asset(cat.imageAsset!, fit: BoxFit.cover),
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
                          : (isSelected
                                ? cat.gradientColors
                                : [Colors.white, Colors.white]),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(14),
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
                            color: hasImage
                                ? Colors.black.withOpacity(0.35)
                                : (isSelected
                                      ? Colors.white.withOpacity(0.25)
                                      : const Color(0xFFEFF6FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            cat.icon,
                            size: 20,
                            color: hasImage || isSelected
                                ? Colors.white
                                : const Color(0xFF3B82F6),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Iconsax.tick_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: hasImage || isSelected
                                ? Colors.white
                                : const Color(0xFF131826),
                            shadows: hasImage
                                ? const [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 1),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat.tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: hasImage
                                ? Colors.white.withOpacity(0.85)
                                : (isSelected
                                      ? Colors.white70
                                      : const Color(0xFF64748B)),
                            shadows: hasImage
                                ? const [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ]
                                : null,
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

  Widget _buildQuizControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Difficulty Setting
        const Text(
          'Difficulty Level',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF131826),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['easy', 'medium', 'hard', 'any'].map((diff) {
            final isSelected = _selectedDifficulty == diff;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      diff.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF10141E),
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDifficulty = diff;
                      });
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Questions Count
        const Text(
          'Number of Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF131826),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [5, 10, 15, 20].map((count) {
            final isSelected = _questionCount == count;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      '$count Qs',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6A9BFA),
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _questionCount = count;
                      });
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Start Quiz Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10141E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Launch Quiz Challenge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
