import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/illustrations.dart';
import '../widgets/podium_widget.dart';
import '../widgets/sunburst_background.dart';
import '../theme/pill_border.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = Provider.of<LeaderboardProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentUserId = auth.userProfile?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FC),
      body: SunburstBackground(
        opacity: 0.5,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => leaderboard.loadLeaderboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Month Selector Badge ("November")
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC833),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [PillBorder.small(offset: 2.0)],
                    ),
                    child: PopupMenuButton<String>(
                      initialValue: leaderboard.selectedMonth,
                      onSelected: leaderboard.setMonth,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            leaderboard.selectedMonth,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF131826),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF131826),
                          ),
                        ],
                      ),
                      itemBuilder: (context) =>
                          [
                            'November',
                            'October',
                            'September',
                            'All-Time Season',
                          ].map((month) {
                            return PopupMenuItem(
                              value: month,
                              child: Text(
                                month,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Curved "Leaderboard" pill container
                  Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E7FD),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        PillBorder.medium(offset: 2.5),
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF131826),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3D Podium for 1st, 2nd, 3rd
                  PodiumWidget(
                    firstPlace: leaderboard.firstPlace,
                    secondPlace: leaderboard.secondPlace,
                    thirdPlace: leaderboard.thirdPlace,
                  ),

                  // White curved sheet for Ranks #4 and beyond
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(38),
                        topRight: Radius.circular(38),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        if (leaderboard.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (leaderboard.remainingRanks.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'No extra players ranked yet.\nComplete quizzes to join the board!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: leaderboard.remainingRanks.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final player = leaderboard.remainingRanks[index];
                              final rankNumber = index + 4;
                              final isCurrentUser = player.id == currentUserId;

                              return _buildRankCard(
                                player: player,
                                rankNumber: rankNumber,
                                isCurrentUser: isCurrentUser,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankCard({
    required UserProfileModel player,
    required int rankNumber,
    required bool isCurrentUser,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFEBF4FE) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          PillBorder.userTile(
            offset: 2.5,
            color: isCurrentUser ? const Color(0xFF6A9BFA) : PillBorder.grey,
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Number (#4, #5, #6)
          SizedBox(
            width: 38,
            child: Text(
              '#$rankNumber',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF131826),
              ),
            ),
          ),

          // Avatar
          AvatarCircle(avatarKey: player.avatarUrl, size: 46),
          const SizedBox(width: 14),

          // Player Name & Gems
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.username,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131826),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A9BFA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Diamond Score Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4E7FD),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      PillBorder.tiny(offset: 1.5, color: PillBorder.dark),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const StarIllustration(size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${player.gems}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rank Trend Indicator (Green Up Triangle or Orange Down Triangle)
          if (player.rankTrend > 0)
            const Icon(
              Icons.arrow_drop_up_rounded,
              color: Color(0xFF10B981),
              size: 28,
            )
          else if (player.rankTrend < 0)
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: Color(0xFFF97316),
              size: 28,
            )
          else
            const Icon(
              Icons.remove_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
        ],
      ),
    );
  }
}
