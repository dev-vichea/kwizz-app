import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../theme/pill_border.dart';
import 'avatar_circle.dart';
import 'illustrations.dart';

class PodiumWidget extends StatelessWidget {
  final UserProfileModel? firstPlace;
  final UserProfileModel? secondPlace;
  final UserProfileModel? thirdPlace;

  const PodiumWidget({
    super.key,
    this.firstPlace,
    this.secondPlace,
    this.thirdPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd Place (Left, Yellow pedestal)
          Expanded(
            child: _buildPodiumColumn(
              user: secondPlace,
              rank: 2,
              pedestalHeight: 110,
              frontColor: const Color(0xFFFDE68A),
              sideColor: const Color(0xFFF59E0B),
              topColor: const Color(0xFFFEF3C7),
            ),
          ),
          const SizedBox(width: 8),

          // 1st Place (Center, Green pedestal - Tallest)
          Expanded(
            child: _buildPodiumColumn(
              user: firstPlace,
              rank: 1,
              pedestalHeight: 145,
              frontColor: const Color(0xFFA7F3D0),
              sideColor: const Color(0xFF10B981),
              topColor: const Color(0xFFD1FAE5),
            ),
          ),
          const SizedBox(width: 8),

          // 3rd Place (Right, Pink pedestal - Lowest)
          Expanded(
            child: _buildPodiumColumn(
              user: thirdPlace,
              rank: 3,
              pedestalHeight: 85,
              frontColor: const Color(0xFFFBCFE8),
              sideColor: const Color(0xFFEC4899),
              topColor: const Color(0xFFFDF2F8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required UserProfileModel? user,
    required int rank,
    required double pedestalHeight,
    required Color frontColor,
    required Color sideColor,
    required Color topColor,
  }) {
    if (user == null) {
      return const SizedBox();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with rank badge
        AvatarCircle(
          avatarKey: user.avatarUrl,
          size: rank == 1 ? 68 : 58,
          rank: rank,
          showRankBadge: true,
        ),
        const SizedBox(height: 6),

        // Name
        Text(
          user.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: rank == 1 ? 14 : 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF131826),
          ),
        ),
        const SizedBox(height: 4),

        // Diamond Score Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: rank == 1
                ? const Color(0xFFE0ECFD)
                : rank == 2
                    ? const Color(0xFFFEF9C3)
                    : const Color(0xFFFCE7F3),
            borderRadius: BorderRadius.circular(16),
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
                '${user.gems}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 3D Isometric Pedestal Block
        CustomPaint(
          size: Size(double.infinity, pedestalHeight),
          painter: _PodiumBlockPainter(
            frontColor: frontColor,
            sideColor: sideColor,
            topColor: topColor,
            rank: rank,
          ),
        ),
      ],
    );
  }
}

class _PodiumBlockPainter extends CustomPainter {
  final Color frontColor;
  final Color sideColor;
  final Color topColor;
  final int rank;

  _PodiumBlockPainter({
    required this.frontColor,
    required this.sideColor,
    required this.topColor,
    required this.rank,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const double bevel = 12.0;

    // Top Facet (Trapezoid / Parallelogram)
    final topPaint = Paint()
      ..color = topColor
      ..style = PaintingStyle.fill;

    final topPath = Path()
      ..moveTo(0, bevel)
      ..lineTo(bevel, 0)
      ..lineTo(w, 0)
      ..lineTo(w - bevel, bevel)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Front Facet (Main block)
    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          frontColor,
          frontColor.withOpacity(0.85),
        ],
      ).createShader(Rect.fromLTWH(0, bevel, w - bevel, h - bevel))
      ..style = PaintingStyle.fill;

    final frontRect = Rect.fromLTWH(0, bevel, w - bevel, h - bevel);
    canvas.drawRect(frontRect, frontPaint);

    // Right Side Facet (Isometric side)
    final sidePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          sideColor.withOpacity(0.4),
          sideColor.withOpacity(0.2),
        ],
      ).createShader(Rect.fromLTWH(w - bevel, 0, bevel, h))
      ..style = PaintingStyle.fill;

    final sidePath = Path()
      ..moveTo(w - bevel, bevel)
      ..lineTo(w, 0)
      ..lineTo(w, h - bevel)
      ..lineTo(w - bevel, h)
      ..close();
    canvas.drawPath(sidePath, sidePaint);
  }

  @override
  bool shouldRepaint(covariant _PodiumBlockPainter oldDelegate) => false;
}
