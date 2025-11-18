import 'package:flutter/material.dart';

/// Design System Constants - Spacing, Sizing, và Layout
class AppSpacing {
  // Spacing scale (8px base)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Padding presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: lg,
  );

  // Gap (for spacing between widgets)
  static Widget gapXS = const SizedBox(height: xs, width: xs);
  static Widget gapSM = const SizedBox(height: sm, width: sm);
  static Widget gapMD = const SizedBox(height: md, width: md);
  static Widget gapLG = const SizedBox(height: lg, width: lg);
  static Widget gapXL = const SizedBox(height: xl, width: xl);
  static Widget gapXXL = const SizedBox(height: xxl, width: xxl);

  static Widget gapH(double width) => SizedBox(width: width);
  static Widget gapV(double height) => SizedBox(height: height);
}

/// Border Radius Constants
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;

  static BorderRadius radiusSM = BorderRadius.circular(sm);
  static BorderRadius radiusMD = BorderRadius.circular(md);
  static BorderRadius radiusLG = BorderRadius.circular(lg);
  static BorderRadius radiusXL = BorderRadius.circular(xl);
  static BorderRadius radiusXXL = BorderRadius.circular(xxl);
  static BorderRadius radiusFull = BorderRadius.circular(full);

  // Specific corners
  static BorderRadius radiusTopSM = const BorderRadius.vertical(
    top: Radius.circular(sm),
  );
  static BorderRadius radiusTopMD = const BorderRadius.vertical(
    top: Radius.circular(md),
  );
  static BorderRadius radiusTopLG = const BorderRadius.vertical(
    top: Radius.circular(lg),
  );

  static BorderRadius radiusBottomSM = const BorderRadius.vertical(
    bottom: Radius.circular(sm),
  );
  static BorderRadius radiusBottomMD = const BorderRadius.vertical(
    bottom: Radius.circular(md),
  );
  static BorderRadius radiusBottomLG = const BorderRadius.vertical(
    bottom: Radius.circular(lg),
  );
}

/// Shadow Constants
class AppShadows {
  static List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // Colored shadows (for emphasis) - Deep Blue Glow
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: const Color(0xFF1565C0).withValues(alpha: 0.5),
      blurRadius: 28,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
      blurRadius: 45,
      spreadRadius: 5,
    ),
  ];

  static List<BoxShadow> accentGlow = [
    BoxShadow(
      color: const Color(0xFF0EA5E9).withValues(alpha: 0.5),
      blurRadius: 28,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: const Color(0xFF1565C0).withValues(alpha: 0.3),
      blurRadius: 45,
      spreadRadius: 5,
    ),
  ];
}

/// Animation Duration Constants
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// Animation Curve Constants
class AppCurves {
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounce = Curves.easeOutBack;
  static const Curve elastic = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
}

/// Breakpoints for responsive design
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
}

/// Icon Sizes
class AppIconSizes {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;
}

/// Typography Sizes (used with GoogleFonts)
class AppFontSizes {
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 20.0;
  static const double h1 = 32.0;
  static const double h2 = 28.0;
  static const double h3 = 24.0;
  static const double h4 = 20.0;
}
