import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/supabase_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<UserProfileModel> _allUsers = [];
  bool _isLoading = false;
  String _selectedMonth = 'November';
  String _selectedScope = 'Monthly'; // Monthly, All Time, Weekly

  List<UserProfileModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String get selectedMonth => _selectedMonth;
  String get selectedScope => _selectedScope;

  UserProfileModel? get firstPlace => _allUsers.isNotEmpty ? _allUsers[0] : null;
  UserProfileModel? get secondPlace => _allUsers.length > 1 ? _allUsers[1] : null;
  UserProfileModel? get thirdPlace => _allUsers.length > 2 ? _allUsers[2] : null;

  List<UserProfileModel> get remainingRanks =>
      _allUsers.length > 3 ? _allUsers.sublist(3) : [];

  LeaderboardProvider() {
    loadLeaderboard();
  }

  void setMonth(String month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setScope(String scope) {
    _selectedScope = scope;
    notifyListeners();
  }

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _supabaseService.getLeaderboard(limit: 30);
      if (list.isNotEmpty) {
        _allUsers = list;
      } else {
        _allUsers = _getFallbackLeaderboard();
      }
    } catch (_) {
      _allUsers = _getFallbackLeaderboard();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<UserProfileModel> _getFallbackLeaderboard() {
    return [
      UserProfileModel(
        id: '11111111-1111-1111-1111-111111111101',
        username: 'Olivia Avo',
        fullName: 'Olivia Avo',
        avatarUrl: 'avatar_1',
        title: 'Quiz Champion',
        gems: 900,
        totalScore: 2450,
        rank: 1,
        rankTrend: 1,
      ),
      UserProfileModel(
        id: '11111111-1111-1111-1111-111111111102',
        username: 'Sophia Cba',
        fullName: 'Sophia Cba',
        avatarUrl: 'avatar_2',
        title: 'Grandmaster',
        gems: 800,
        totalScore: 2180,
        rank: 2,
        rankTrend: 1,
      ),
      UserProfileModel(
        id: '11111111-1111-1111-1111-111111111103',
        username: 'Miu Evelyn',
        fullName: 'Miu Evelyn',
        avatarUrl: 'avatar_3',
        title: 'Pro Scholar',
        gems: 700,
        totalScore: 1920,
        rank: 3,
        rankTrend: -1,
      ),
      UserProfileModel(
        id: '11111111-1111-1111-1111-111111111104',
        username: 'Luna Aira',
        fullName: 'Luna Aira',
        avatarUrl: 'avatar_4',
        title: 'Trivia Wizard',
        gems: 500,
        totalScore: 1500,
        rank: 4,
        rankTrend: 1, // Up arrow green
      ),
      UserProfileModel(
        id: '11111111-1111-1111-1111-111111111105',
        username: 'Clara Zeno',
        fullName: 'Clara Zeno',
        avatarUrl: 'avatar_5',
        title: 'Rising Star',
        gems: 450,
        totalScore: 1310,
        rank: 5,
        rankTrend: -1, // Down arrow orange
      ),
      UserProfileModel(
        id: '11111111-1111-1111-1111-111111111106',
        username: 'Elina Avo',
        fullName: 'Elina Avo',
        avatarUrl: 'avatar_6',
        title: 'Quiz Whiz',
        gems: 400,
        totalScore: 1150,
        rank: 6,
        rankTrend: 1, // Up arrow green
      ),
      UserProfileModel(
        id: '11111111-1111-1111-1111-111111111107',
        username: 'Emily Rose',
        fullName: 'Emily Rose',
        avatarUrl: 'avatar_7',
        title: 'Student',
        gems: 30,
        totalScore: 250,
        rank: 7,
        rankTrend: 0,
      ),
    ];
  }
}
