import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

class StorageService {
  static const String _keyOnboardingSeen = 'has_seen_onboarding';
  static const String _keyGuestProfile = 'guest_user_profile';
  static const String _keyFavoriteCategories = 'favorite_categories';

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingSeen, value);
  }

  Future<UserProfileModel?> getSavedLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyGuestProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> map = json.decode(jsonStr);
        return UserProfileModel.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveLocalProfile(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGuestProfile, json.encode(profile.toJson()));
  }

  Future<List<int>> getFavoriteCategoryIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyFavoriteCategories);
    if (list != null) {
      return list
          .map((e) => int.tryParse(e) ?? 0)
          .where((id) => id > 0)
          .toList();
    }
    return [18]; // 18 is Tech by default
  }

  Future<void> toggleFavoriteCategory(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavoriteCategoryIds();
    if (favs.contains(categoryId)) {
      favs.remove(categoryId);
    } else {
      favs.add(categoryId);
    }
    await prefs.setStringList(
      _keyFavoriteCategories,
      favs.map((e) => e.toString()).toList(),
    );
  }
}
