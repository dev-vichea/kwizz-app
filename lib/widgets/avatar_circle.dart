import 'package:flutter/material.dart';
import '../utils/avatar_helper.dart';

class AvatarCircle extends StatelessWidget {
  final String avatarKey;
  final double size;
  final int? rank;
  final bool showRankBadge;
  final VoidCallback? onTap;

  const AvatarCircle({
    super.key,
    required this.avatarKey,
    this.size = 50,
    this.rank,
    this.showRankBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = AvatarHelper.getConfig(avatarKey);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Outer subtle glow / border
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.bgColor,
              border: Border.all(
                color: _getBorderColor(rank),
                width: rank != null && rank! <= 3 ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: CustomPaint(
                size: Size(size, size),
                painter: _AvatarPainter(config: config),
              ),
            ),
          ),

          // Rank Badge if applicable (1, 2, 3)
          if (showRankBadge && rank != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getRankBadgeColor(rank!),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBorderColor(int? rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFE2E8F0); // Silver / White
    if (rank == 3) return const Color(0xFFFDBA74); // Bronze / Peach
    return Colors.white;
  }

  Color _getRankBadgeColor(int rank) {
    if (rank == 1) return const Color(0xFFFFC833);
    if (rank == 2) return const Color(0xFFFFD84D);
    if (rank == 3) return const Color(0xFFFFB347);
    return Colors.amber;
  }
}

class _AvatarPainter extends CustomPainter {
  final AvatarConfig config;

  _AvatarPainter({required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body / Shirt
    final shirtPaint = Paint()
      ..color = config.clothColor
      ..style = PaintingStyle.fill;

    final shirtPath = Path()
      ..moveTo(w * 0.15, h)
      ..quadraticBezierTo(w * 0.25, h * 0.68, w * 0.5, h * 0.68)
      ..quadraticBezierTo(w * 0.75, h * 0.68, w * 0.85, h)
      ..close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Collar detail
    final collarPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    final collarPath = Path()
      ..moveTo(w * 0.42, h * 0.68)
      ..lineTo(w * 0.5, h * 0.78)
      ..lineTo(w * 0.58, h * 0.68)
      ..close();
    canvas.drawPath(collarPath, collarPaint);

    // Head / Face
    final facePaint = Paint()
      ..color = config.skinColor
      ..style = PaintingStyle.fill;

    final faceRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.45),
      width: w * 0.50,
      height: h * 0.52,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(w * 0.24)),
      facePaint,
    );

    // Hair
    final hairPaint = Paint()
      ..color = config.hairColor
      ..style = PaintingStyle.fill;

    final hairPath = Path()
      ..moveTo(w * 0.22, h * 0.42)
      ..quadraticBezierTo(w * 0.20, h * 0.15, w * 0.5, h * 0.15)
      ..quadraticBezierTo(w * 0.80, h * 0.15, w * 0.78, h * 0.42)
      ..quadraticBezierTo(w * 0.65, h * 0.28, w * 0.5, h * 0.28)
      ..quadraticBezierTo(w * 0.35, h * 0.28, w * 0.22, h * 0.42)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.41, h * 0.45), w * 0.04, eyePaint);
    canvas.drawCircle(Offset(w * 0.59, h * 0.45), w * 0.04, eyePaint);

    // Glasses
    if (config.hasGlasses) {
      final glassesPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035;

      canvas.drawCircle(Offset(w * 0.41, h * 0.45), w * 0.09, glassesPaint);
      canvas.drawCircle(Offset(w * 0.59, h * 0.45), w * 0.09, glassesPaint);
      canvas.drawLine(
        Offset(w * 0.49, h * 0.45),
        Offset(w * 0.51, h * 0.45),
        glassesPaint,
      );
    }

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF991B1B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(w * 0.45, h * 0.56)
      ..quadraticBezierTo(w * 0.5, h * 0.61, w * 0.55, h * 0.56);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      oldDelegate.config != config;
}
