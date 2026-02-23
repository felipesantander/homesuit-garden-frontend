import 'package:flutter/material.dart';

/// Sistema de espaciado reutilizable para Material Design
class AppSpacing {
  // ==================== ESPACIADO VERTICAL ====================

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double xxxxl = 40.0;

  // ==================== WIDGETS DE ESPACIADO ====================

  static const Widget verticalXS = SizedBox(height: xs);
  static const Widget verticalSM = SizedBox(height: sm);
  static const Widget verticalMD = SizedBox(height: md);
  static const Widget verticalLG = SizedBox(height: lg);
  static const Widget verticalXL = SizedBox(height: xl);
  static const Widget verticalXXL = SizedBox(height: xxl);
  static const Widget verticalXXXL = SizedBox(height: xxxl);

  // ==================== ESPACIADO HORIZONTAL ====================

  static const Widget horizontalXS = SizedBox(width: xs);
  static const Widget horizontalSM = SizedBox(width: sm);
  static const Widget horizontalMD = SizedBox(width: md);
  static const Widget horizontalLG = SizedBox(width: lg);
  static const Widget horizontalXL = SizedBox(width: xl);
  static const Widget horizontalXXL = SizedBox(width: xxl);
  static const Widget horizontalXXXL = SizedBox(width: xxxl);

  // ==================== PADDING PRESETS ====================

  static const EdgeInsets paddingAllSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMD = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingAllXXL = EdgeInsets.all(xxl);
  static const EdgeInsets paddingAllXXXL = EdgeInsets.all(xxxl);

  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: xl,
  );

  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: lg,
  );
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: xl,
  );
}

/// Sistema de tamaños de iconos reutilizable
class AppIconSizes {
  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;
}

/// Sistema de bordes redondeados reutilizable
class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double circular = 100.0;

  static BorderRadius get borderRadiusSM => BorderRadius.circular(sm);
  static BorderRadius get borderRadiusMD => BorderRadius.circular(md);
  static BorderRadius get borderRadiusLG => BorderRadius.circular(lg);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(xl);
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(xxl);
  static BorderRadius get borderRadiusCircular =>
      BorderRadius.circular(circular);
}
