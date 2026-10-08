import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CategoryModel {
  final int id;
  final String name;
  final String displayName;
  final String tag;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isPopular;
  final String? imageAsset;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.tag,
    required this.description,
    required this.icon,
    required this.gradientColors,
    this.isPopular = false,
    this.imageAsset,
  });

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 18,
      name: 'Science: Computers',
      displayName: 'Future of Tech',
      tag: 'Tech',
      description: 'Explore technology through fun quizzes and prove you can grow from beginner to true tech master.',
      icon: Iconsax.cpu,
      gradientColors: [Color(0xFFFF9EBA), Color(0xFFFF5288)],
      isPopular: true,
      imageAsset: 'assets/future-tech.jpeg',
    ),
    CategoryModel(
      id: 17,
      name: 'Science & Nature',
      displayName: 'Science & Cosmos',
      tag: 'Science',
      description: 'Journey through planets, biology, physics, and cosmic wonders of nature.',
      icon: Iconsax.flash,
      gradientColors: [Color(0xFF818CF8), Color(0xFF6366F1)],
      isPopular: true,
      imageAsset: 'assets/science.jpeg',
    ),
    CategoryModel(
      id: 9,
      name: 'General Knowledge',
      displayName: 'World Trivia',
      tag: 'General',
      description: 'Test your everyday knowledge across diverse facts and mysteries.',
      icon: Iconsax.global,
      gradientColors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      isPopular: true,
      imageAsset: 'assets/general.jpeg',
    ),
    CategoryModel(
      id: 23,
      name: 'History',
      displayName: 'Historical Eras',
      tag: 'History',
      description: 'Step into the past and discover ancient civilizations and revolutionary events.',
      icon: Iconsax.book,
      gradientColors: [Color(0xFFFBBF24), Color(0xFFD97706)],
      imageAsset: 'assets/historical.jpeg',
    ),
    CategoryModel(
      id: 21,
      name: 'Sports',
      displayName: 'Athletics & Sports',
      tag: 'Sports',
      description: 'Challenge yourself with football, basketball, olympics, and legendary champions.',
      icon: Iconsax.medal,
      gradientColors: [Color(0xFF34D399), Color(0xFF059669)],
      imageAsset: 'assets/sport.jpeg',
    ),
    CategoryModel(
      id: 15,
      name: 'Entertainment: Video Games',
      displayName: 'Video Games Realm',
      tag: 'Gaming',
      description: 'From retro arcade classics to modern RPGs and competitive esports.',
      icon: Iconsax.game,
      gradientColors: [Color(0xFFA855F7), Color(0xFF7E22CE)],
      imageAsset: 'assets/video-game.jpeg',
    ),
    CategoryModel(
      id: 11,
      name: 'Entertainment: Film',
      displayName: 'Cinema & Movies',
      tag: 'Movies',
      description: 'Blockbusters, iconic directors, Oscar winners, and Hollywood trivia.',
      icon: Iconsax.video_play,
      gradientColors: [Color(0xFFFB7185), Color(0xFFE11D48)],
      imageAsset: 'assets/cinema-movie.jpeg',
    ),
    CategoryModel(
      id: 12,
      name: 'Entertainment: Music',
      displayName: 'Melody & Music',
      tag: 'Music',
      description: 'Chart-toppers, classic rock, pop icons, and instruments of the world.',
      icon: Iconsax.music,
      gradientColors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
      imageAsset: 'assets/melody-music.jpeg',
    ),
    CategoryModel(
      id: 22,
      name: 'Geography',
      displayName: 'Global Geography',
      tag: 'Geo',
      description: 'Capitals, mountain ranges, oceans, and country flags around the globe.',
      icon: Iconsax.map,
      gradientColors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
      imageAsset: 'assets/geography.jpeg',
    ),
  ];
}
