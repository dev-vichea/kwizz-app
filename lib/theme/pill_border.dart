import 'package:flutter/material.dart';

/// Reusable utility for 3D bottom pill borders across Kwizz cards and badges.
///
/// Features configurable offsets based on card size (large, medium, small, tiny)
/// and configurable colors (e.g. dark for primary cards, grey for user list tiles).
class PillBorder {
  // Predefined border colors
  static const Color dark = Color(0xFF10141E);
  static const Color grey = Color(0xFFCBD5E1);
  static const Color greyDark = Color(0xFF94A3B8);
  static const Color greyLight = Color(0xFFE2E8F0);

  /// Returns a zero-blur BoxShadow creating a crisp 3D bottom pill border.
  static BoxShadow shadow({
    double offset = 3.0,
    Color color = dark,
  }) {
    return BoxShadow(
      color: color,
      offset: Offset(0, offset),
      blurRadius: 0,
    );
  }

  /// Large card bottom border (e.g. Hero banners, Featured cards).
  /// Default offset: 3.0 to 4.0.
  static BoxShadow large({
    double offset = 3.0,
    Color color = dark,
  }) => shadow(offset: offset, color: color);

  /// Medium card bottom border (e.g. Pill banners, Category cards).
  /// Default offset: 2.0 to 2.5.
  static BoxShadow medium({
    double offset = 2.0,
    Color color = dark,
  }) => shadow(offset: offset, color: color);

  /// Small card / button bottom border.
  /// Default offset: 2.0.
  static BoxShadow small({
    double offset = 2.0,
    Color color = dark,
  }) => shadow(offset: offset, color: color);

  /// Tiny badge / Stars pill bottom border (e.g. Star 500 tag).
  /// Default offset: 1.5.
  static BoxShadow tiny({
    double offset = 1.5,
    Color color = dark,
  }) => shadow(offset: offset, color: color);

  /// User tile bottom border (Grey bottom border for white user cards, matching screenshots).
  /// Default offset: 2.5, color: grey.
  static BoxShadow userTile({
    double offset = 2.5,
    Color color = grey,
  }) => shadow(offset: offset, color: color);

  /// Returns shadows list containing the solid bottom border + optional soft ambient blur.
  static List<BoxShadow> shadows({
    double offset = 3.0,
    Color color = dark,
    Color? ambientColor,
    double ambientBlur = 14.0,
    Offset? ambientOffset,
  }) {
    return [
      shadow(offset: offset, color: color),
      if (ambientColor != null)
        BoxShadow(
          color: ambientColor,
          blurRadius: ambientBlur,
          offset: ambientOffset ?? Offset(0, offset + 3),
        ),
    ];
  }

  /// Convenience BoxDecoration builder for cards with bottom pill borders.
  static BoxDecoration decoration({
    Color? color,
    Gradient? gradient,
    BorderRadiusGeometry? borderRadius,
    double radius = 24.0,
    double offset = 3.0,
    Color borderColor = dark,
    Border? border,
    Color? ambientColor,
    double ambientBlur = 14.0,
  }) {
    return BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      border: border,
      boxShadow: shadows(
        offset: offset,
        color: borderColor,
        ambientColor: ambientColor,
        ambientBlur: ambientBlur,
      ),
    );
  }
}
