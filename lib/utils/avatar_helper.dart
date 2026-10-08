import 'package:flutter/material.dart';

class AvatarConfig {
  final String id;
  final String name;
  final Color bgColor;
  final Color hairColor;
  final Color skinColor;
  final Color clothColor;
  final bool hasGlasses;
  final IconData placeholderIcon;

  const AvatarConfig({
    required this.id,
    required this.name,
    required this.bgColor,
    required this.hairColor,
    required this.skinColor,
    required this.clothColor,
    this.hasGlasses = false,
    this.placeholderIcon = Icons.person_rounded,
  });
}

class AvatarHelper {
  static const Map<String, AvatarConfig> avatars = {
    'avatar_1': AvatarConfig(
      id: 'avatar_1',
      name: 'Olivia Avo',
      bgColor: Color(0xFFC7F2D6), // Mint green
      hairColor: Color(0xFF5D3A1A),
      skinColor: Color(0xFFFFDFC4),
      clothColor: Color(0xFF6366F1),
      hasGlasses: false,
      placeholderIcon: Icons.face_rounded,
    ),
    'avatar_2': AvatarConfig(
      id: 'avatar_2',
      name: 'Sophia Cba',
      bgColor: Color(0xFFFEE685), // Yellow
      hairColor: Color(0xFF2C1810),
      skinColor: Color(0xFFFCD0B3),
      clothColor: Color(0xFFEAB308),
      hasGlasses: true,
      placeholderIcon: Icons.face_3_rounded,
    ),
    'avatar_3': AvatarConfig(
      id: 'avatar_3',
      name: 'Miu Evelyn',
      bgColor: Color(0xFFFBCFE8), // Pink
      hairColor: Color(0xFF1E293B),
      skinColor: Color(0xFFFFDFC4),
      clothColor: Color(0xFF8B5CF6),
      hasGlasses: true,
      placeholderIcon: Icons.face_6_rounded,
    ),
    'avatar_4': AvatarConfig(
      id: 'avatar_4',
      name: 'Luna Aira',
      bgColor: Color(0xFFE2E8F0),
      hairColor: Color(0xFF422006),
      skinColor: Color(0xFFFCD0B3),
      clothColor: Color(0xFF0284C7),
      hasGlasses: true,
      placeholderIcon: Icons.face_4_rounded,
    ),
    'avatar_5': AvatarConfig(
      id: 'avatar_5',
      name: 'Clara Zeno',
      bgColor: Color(0xFFE2E8F0),
      hairColor: Color(0xFF18181B),
      skinColor: Color(0xFFFFDFC4),
      clothColor: Color(0xFF0F172A),
      hasGlasses: false,
      placeholderIcon: Icons.face_rounded,
    ),
    'avatar_6': AvatarConfig(
      id: 'avatar_6',
      name: 'Elina Avo',
      bgColor: Color(0xFFE2E8F0),
      hairColor: Color(0xFF78350F),
      skinColor: Color(0xFFFFDFC4),
      clothColor: Color(0xFF3B82F6),
      hasGlasses: true,
      placeholderIcon: Icons.face_5_rounded,
    ),
    'avatar_7': AvatarConfig(
      id: 'avatar_7',
      name: 'Emily Rose',
      bgColor: Color(0xFFBFDBFE), // Light sky blue
      hairColor: Color(0xFF451A03),
      skinColor: Color(0xFFFFDFC4),
      clothColor: Color(0xFF3B82F6),
      hasGlasses: true,
      placeholderIcon: Icons.face_2_rounded,
    ),
  };

  static AvatarConfig getConfig(String? key) {
    if (key != null && avatars.containsKey(key)) {
      return avatars[key]!;
    }
    return avatars['avatar_7']!;
  }
}
