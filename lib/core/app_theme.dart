import 'package:flutter/material.dart';

class AppColors {
  static const midnight = Color(0xFF12002B);
  static const royalPurple = Color(0xFF43106E);
  static const neonMagenta = Color(0xFFF018B8);
  static const electricBlue = Color(0xFF087CFF);
  static const cyan = Color(0xFF34E6FF);
  static const jokerRed = Color(0xFFF23838);
  static const gold = Color(0xFFFFC928);
  static const cream = Color(0xFFFFF3D2);
  static const ink = Color(0xFF24002F);
  static const success = Color(0xFF5DFF93);
  static const failure = Color(0xFFFF5964);
}

class AppTheme {
  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.midnight,
      canvasColor: AppColors.midnight,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      fontFamily: 'Nunito',
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: 'Nunito',
        bodyColor: AppColors.cream,
        displayColor: AppColors.cream,
      ),
      colorScheme: const ColorScheme.dark(
        surface: AppColors.midnight,
        primary: AppColors.neonMagenta,
        secondary: AppColors.gold,
        error: AppColors.failure,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.gold,
        inactiveTrackColor: AppColors.royalPurple,
        thumbColor: AppColors.cream,
        overlayColor: AppColors.gold.withValues(alpha: 0.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.ink;
          return AppColors.cream;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.gold;
          return AppColors.royalPurple;
        }),
      ),
    );
  }

  static TextStyle display(
    double size, {
    Color color = AppColors.cream,
    FontWeight weight = FontWeight.w700,
    bool shadow = true,
  }) {
    return TextStyle(
      fontFamily: 'Cinzel',
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color,
      height: 1.15,
      letterSpacing: 0.4,
      shadows: shadow ? _legibility : null,
    );
  }

  static TextStyle body(
    double size, {
    Color color = AppColors.cream,
    FontWeight weight = FontWeight.w700,
    double height = 1.35,
    bool shadow = true,
  }) {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color,
      height: height,
      shadows: shadow ? _legibility : null,
    );
  }

  static const _legibility = [
    Shadow(color: Color(0xF012002B), blurRadius: 8, offset: Offset(0, 1)),
    Shadow(color: Color(0xCC000000), blurRadius: 2),
  ];
}

/// Dark plate so cream type stays readable on bright theatrical art.
class InkPanel extends StatelessWidget {
  const InkPanel({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 14)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE612002B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.9), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class ContentFrame extends StatelessWidget {
  const ContentFrame({super.key, required this.child, this.padding = 20});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: child,
          ),
        ),
      ),
    );
  }
}
