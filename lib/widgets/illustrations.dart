import 'package:flutter/material.dart';

/// 3D Golden Trophy with star and ribbons (champion.png)
class TrophyIllustration extends StatelessWidget {
  final double size;

  const TrophyIllustration({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/champion.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// 3D Golden Crown for "Upgrade Pro" (crown.png)
class CrownIllustration extends StatelessWidget {
  final double size;

  const CrownIllustration({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/crown.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Tech VR Character Illustration (tech-girl.png)
class TechCharacterIllustration extends StatelessWidget {
  final double size;

  const TechCharacterIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/tech-girl.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Open Book with Glowing Lightbulb (golden-book.png)
class BookLightbulbIllustration extends StatelessWidget {
  final double size;

  const BookLightbulbIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/golden-book.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// 3D Golden Star (star.png)
class StarIllustration extends StatelessWidget {
  final double size;

  const StarIllustration({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/star.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
