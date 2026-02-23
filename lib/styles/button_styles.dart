import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';

/// Sistema de estilos de botones reutilizable para Material Design
class AppButtonStyles {
  // ==================== ESTILOS DE BOTÓN ====================

  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 2,
  );

  static ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static ButtonStyle danger = ElevatedButton.styleFrom(
    backgroundColor: AppColors.negative,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 2,
  );

  static ButtonStyle success = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary, // Mint Green
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 2,
  );

  static ButtonStyle small = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    elevation: 1,
    minimumSize: const Size(0, 32),
  );

  static ButtonStyle large = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 3,
    minimumSize: const Size(0, 52),
  );

  // ==================== DECORACIONES DE ICONO ====================

  static const EdgeInsets iconPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 10,
  );

  static const double iconSpacing = 8.0;

  // ==================== TAMAÑOS ====================

  static const double heightStandard = 44.0;
  static const double heightSmall = 32.0;
  static const double heightLarge = 52.0;

  // ==================== BORDER RADIUS ====================

  static const double borderRadiusStandard = 8.0;
  static const double borderRadiusSmall = 6.0;
  static const double borderRadiusLarge = 10.0;
  static const double borderRadiusCircular = 100.0;
}
