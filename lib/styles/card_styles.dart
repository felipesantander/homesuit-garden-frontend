import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:garden_homesuit/config/app_colors.dart';

/// Sistema de estilos de tarjetas reutilizable para Material Design
class AppCardStyles {
  // ==================== DECORACIONES DE CARDS ====================

  static BoxDecoration glassDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.glassBackground,
      borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.2),
        width: borderWidth ?? 1.5,
      ),
    );
  }

  static BoxDecoration glassShadowDecoration({double? borderRadius}) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
      boxShadow: [
        BoxShadow(
          color: AppColors.glassShadow,
          spreadRadius: 2,
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration solidDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth ?? 1.0)
          : null,
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow,
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ==================== PADDING Y SPACING ====================

  static const EdgeInsets paddingStandard = EdgeInsets.all(20.0);
  static const EdgeInsets paddingCompact = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);
  static const EdgeInsets paddingSmall = EdgeInsets.all(12.0);

  // ==================== BORDER RADIUS ====================

  static const double borderRadiusStandard = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;

  // ==================== BLUR EFFECTS ====================

  static ImageFilter get blurStandard =>
      ImageFilter.blur(sigmaX: 10, sigmaY: 10);
  static ImageFilter get blurIntense =>
      ImageFilter.blur(sigmaX: 15, sigmaY: 15);
  static ImageFilter get blurSoft => ImageFilter.blur(sigmaX: 5, sigmaY: 5);

  // ==================== BORDES ====================

  static Color get borderColorStandard => AppColors.border;
  static Color get borderColorHighlight =>
      AppColors.primary.withValues(alpha: 0.3);
  static Color get borderColorSubtle => AppColors.border.withValues(alpha: 0.5);

  static const double borderWidthStandard = 1.0;
  static const double borderWidthThin = 0.5;
  static const double borderWidthThick = 2.0;
}
