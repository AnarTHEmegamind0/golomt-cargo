import 'package:flutter/material.dart';

/// Design version enum for 5 distinct design aesthetics
enum DesignVersion {
  glassmorphism, // v1: Frosted glass, blur, soft borders
  neumorphism, // v2: Soft shadows, inset, organic shapes
  minimal, // v3: Flat, typography-heavy, max whitespace
  cyberpunk, // v4: Angular, neon strokes, dark overlays
  luxury, // v5: Smooth borders, elevation shadows, gold accents
}

/// Extension to provide display names and descriptions
extension DesignVersionExtension on DesignVersion {
  String get displayName {
    switch (this) {
      case DesignVersion.glassmorphism:
        return 'Glassmorphism';
      case DesignVersion.neumorphism:
        return 'Neumorphism';
      case DesignVersion.minimal:
        return 'Minimal';
      case DesignVersion.cyberpunk:
        return 'Cyberpunk';
      case DesignVersion.luxury:
        return 'Luxury';
    }
  }

  String get description {
    switch (this) {
      case DesignVersion.glassmorphism:
        return 'Frosted glass with blur effects';
      case DesignVersion.neumorphism:
        return 'Soft shadows and organic shapes';
      case DesignVersion.minimal:
        return 'Clean, typography-focused design';
      case DesignVersion.cyberpunk:
        return 'Angular with neon accents';
      case DesignVersion.luxury:
        return 'Elegant with gold accents';
    }
  }

  int get version {
    switch (this) {
      case DesignVersion.glassmorphism:
        return 1;
      case DesignVersion.neumorphism:
        return 2;
      case DesignVersion.minimal:
        return 3;
      case DesignVersion.cyberpunk:
        return 4;
      case DesignVersion.luxury:
        return 5;
    }
  }

  static DesignVersion fromVersion(int version) {
    switch (version) {
      case 1:
        return DesignVersion.glassmorphism;
      case 2:
        return DesignVersion.neumorphism;
      case 3:
        return DesignVersion.minimal;
      case 4:
        return DesignVersion.cyberpunk;
      case 5:
        return DesignVersion.luxury;
      default:
        return DesignVersion.glassmorphism;
    }
  }
}

/// Design-specific styling configuration
class DesignConfig {
  const DesignConfig({
    required this.borderRadius,
    required this.cardBorderRadius,
    required this.buttonBorderRadius,
    required this.inputBorderRadius,
    required this.shadowDepth,
    required this.blurRadius,
    required this.opacity,
    required this.borderWidth,
    required this.elevation,
    required this.letterSpacing,
    required this.fontWeightAdjustment,
  });

  final double borderRadius;
  final double cardBorderRadius;
  final double buttonBorderRadius;
  final double inputBorderRadius;
  final double shadowDepth;
  final double blurRadius;
  final double opacity;
  final double borderWidth;
  final double elevation;
  final double letterSpacing;
  final int fontWeightAdjustment;

  static DesignConfig forDesign(DesignVersion design) {
    switch (design) {
      case DesignVersion.glassmorphism:
        return const DesignConfig(
          borderRadius: 20,
          cardBorderRadius: 24,
          buttonBorderRadius: 16,
          inputBorderRadius: 18,
          shadowDepth: 10,
          blurRadius: 10,
          opacity: 0.4,
          borderWidth: 1,
          elevation: 0,
          letterSpacing: -0.25,
          fontWeightAdjustment: 0,
        );
      case DesignVersion.neumorphism:
        return const DesignConfig(
          borderRadius: 12,
          cardBorderRadius: 16,
          buttonBorderRadius: 12,
          inputBorderRadius: 12,
          shadowDepth: 8,
          blurRadius: 0,
          opacity: 0,
          borderWidth: 0,
          elevation: 8,
          letterSpacing: 0,
          fontWeightAdjustment: 0,
        );
      case DesignVersion.minimal:
        return const DesignConfig(
          borderRadius: 8,
          cardBorderRadius: 8,
          buttonBorderRadius: 8,
          inputBorderRadius: 8,
          shadowDepth: 0,
          blurRadius: 0,
          opacity: 0,
          borderWidth: 1,
          elevation: 0,
          letterSpacing: 0.5,
          fontWeightAdjustment: -100,
        );
      case DesignVersion.cyberpunk:
        return const DesignConfig(
          borderRadius: 0,
          cardBorderRadius: 0,
          buttonBorderRadius: 0,
          inputBorderRadius: 0,
          shadowDepth: 0,
          blurRadius: 0,
          opacity: 0.8,
          borderWidth: 2,
          elevation: 0,
          letterSpacing: 2,
          fontWeightAdjustment: 100,
        );
      case DesignVersion.luxury:
        return const DesignConfig(
          borderRadius: 24,
          cardBorderRadius: 28,
          buttonBorderRadius: 20,
          inputBorderRadius: 20,
          shadowDepth: 16,
          blurRadius: 0,
          opacity: 0,
          borderWidth: 0.5,
          elevation: 12,
          letterSpacing: 1,
          fontWeightAdjustment: 0,
        );
    }
  }
}

class AppTheme {
  // Base colors - orange/blue foundation
  static const _accentOrange = Color(0xFFF08A1A);
  static const _accentBlue = Color(0xFF2563EB);
  static const _lightBackground = Color(0xFFF0F2F6);
  static const _darkBackground = Color(0xFF111827);

  // Legacy methods for backward compatibility
  static ThemeData light() =>
      design(DesignVersion.glassmorphism, Brightness.light);
  static ThemeData dark() =>
      design(DesignVersion.glassmorphism, Brightness.dark);

  /// Main factory method for design-based theming
  static ThemeData design(DesignVersion version, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final config = DesignConfig.forDesign(version);

    switch (version) {
      case DesignVersion.glassmorphism:
        return _buildGlassmorphism(isLight, config);
      case DesignVersion.neumorphism:
        return _buildNeumorphism(isLight, config);
      case DesignVersion.minimal:
        return _buildMinimal(isLight, config);
      case DesignVersion.cyberpunk:
        return _buildCyberpunk(isLight, config);
      case DesignVersion.luxury:
        return _buildLuxury(isLight, config);
    }
  }

  // ============================================
  // V1: GLASSMORPHISM
  // Frosted glass (40% opacity), backdrop blur (10px),
  // soft borders (20px), accent glow effects
  // ============================================
  static ThemeData _buildGlassmorphism(bool isLight, DesignConfig config) {
    final scheme = isLight
        ? ColorScheme.fromSeed(
            seedColor: _accentOrange,
            brightness: Brightness.light,
          ).copyWith(
            primary: _accentOrange,
            secondary: const Color(0xFFD96A12),
            surface: Colors.white.withValues(alpha: 0.85),
            error: const Color(0xFFB3261E),
          )
        : ColorScheme.fromSeed(
            seedColor: _accentOrange,
            brightness: Brightness.dark,
          ).copyWith(
            primary: const Color(0xFFF4A142),
            secondary: const Color(0xFFE98A22),
            surface: const Color(0xFF1C2537).withValues(alpha: 0.85),
            error: const Color(0xFFFFB4AB),
          );

    final textTheme = _textTheme(
      isLight ? const Color(0xFF1A2234) : const Color(0xFFF1F4FA),
      isLight ? const Color(0xFF5C667C) : const Color(0xFFAAB3C6),
      config,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? _lightBackground : _darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isLight
            ? const Color(0xFF1A2234)
            : const Color(0xFFF1F4FA),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
        ),
        shadowColor: scheme.primary.withValues(alpha: 0.15),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          elevation: 0,
          shadowColor: scheme.primary.withValues(alpha: 0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(
            color: isLight ? const Color(0xFFE5DDD7) : const Color(0xFF333F55),
            width: config.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? const Color(0xFFFCFAF8).withValues(alpha: 0.7)
            : const Color(0xFF222C3F).withValues(alpha: 0.7),
        labelStyle: TextStyle(
          color: isLight ? const Color(0xFF5C667C) : const Color(0xFFAAB3C6),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: isLight ? const Color(0xFFE5DDD7) : const Color(0xFF333F55),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: isLight ? const Color(0xFFE5DDD7) : const Color(0xFF333F55),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight
            ? Colors.white.withValues(alpha: 0.85)
            : const Color(0xFF1C2537).withValues(alpha: 0.85),
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : (isLight ? const Color(0xFF7A8495) : const Color(0xFFAAB3C6)),
          ),
        ),
      ),
    );
  }

  // ============================================
  // V2: NEUMORPHISM
  // Soft shadows (up 8px), inset shadows, organic shapes (12px),
  // cool tones, no borders
  // ============================================
  static ThemeData _buildNeumorphism(bool isLight, DesignConfig config) {
    final baseColor = isLight
        ? const Color(0xFFE4E8EF)
        : const Color(0xFF1A1F2E);
    final scheme = isLight
        ? ColorScheme.fromSeed(
            seedColor: _accentBlue,
            brightness: Brightness.light,
          ).copyWith(
            primary: _accentOrange.withValues(alpha: 0.9),
            secondary: _accentBlue,
            surface: baseColor,
            error: const Color(0xFFB3261E),
          )
        : ColorScheme.fromSeed(
            seedColor: _accentBlue,
            brightness: Brightness.dark,
          ).copyWith(
            primary: const Color(0xFFF4A142),
            secondary: _accentBlue.withValues(alpha: 0.8),
            surface: baseColor,
            error: const Color(0xFFFFB4AB),
          );

    final textTheme = _textTheme(
      isLight ? const Color(0xFF2C3E50) : const Color(0xFFE8ECF0),
      isLight ? const Color(0xFF6B7C93) : const Color(0xFF8A9BB0),
      config,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: baseColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isLight
            ? const Color(0xFF2C3E50)
            : const Color(0xFFE8ECF0),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: baseColor,
        elevation: config.elevation,
        shadowColor: isLight
            ? const Color(0xFFBEC8D1)
            : const Color(0xFF0A0D14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: baseColor,
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          elevation: config.elevation / 2,
          shadowColor: isLight
              ? const Color(0xFFBEC8D1)
              : const Color(0xFF0A0D14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          side: BorderSide.none,
          backgroundColor: baseColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          elevation: config.elevation / 2,
          shadowColor: isLight
              ? const Color(0xFFBEC8D1)
              : const Color(0xFF0A0D14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: baseColor,
        labelStyle: TextStyle(
          color: isLight ? const Color(0xFF6B7C93) : const Color(0xFF8A9BB0),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: baseColor,
        elevation: config.elevation,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : (isLight ? const Color(0xFF6B7C93) : const Color(0xFF8A9BB0)),
          ),
        ),
      ),
    );
  }

  // ============================================
  // V3: MINIMAL
  // Flat design, 8px borders, max whitespace (padding 24px),
  // typography-heavy, no shadows
  // ============================================
  static ThemeData _buildMinimal(bool isLight, DesignConfig config) {
    final scheme = isLight
        ? ColorScheme.fromSeed(
            seedColor: _accentOrange,
            brightness: Brightness.light,
          ).copyWith(
            primary: _accentOrange,
            secondary: _accentBlue,
            surface: Colors.white,
            error: const Color(0xFFDC2626),
          )
        : ColorScheme.fromSeed(
            seedColor: _accentOrange,
            brightness: Brightness.dark,
          ).copyWith(
            primary: const Color(0xFFF4A142),
            secondary: const Color(0xFF60A5FA),
            surface: const Color(0xFF18181B),
            error: const Color(0xFFFCA5A5),
          );

    final textTheme = _textTheme(
      isLight ? const Color(0xFF09090B) : const Color(0xFFFAFAFA),
      isLight ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
      config,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? Colors.white : const Color(0xFF09090B),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isLight
            ? const Color(0xFF09090B)
            : const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
          side: BorderSide(
            color: isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
            width: config.borderWidth,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: config.letterSpacing,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(
            color: isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
            width: config.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: config.letterSpacing,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        labelStyle: TextStyle(
          color: isLight ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
          fontWeight: FontWeight.w500,
          letterSpacing: config.letterSpacing,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
            width: config.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
            width: config.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 0,
        indicatorColor: scheme.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            letterSpacing: config.letterSpacing,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : (isLight ? const Color(0xFF71717A) : const Color(0xFFA1A1AA)),
          ),
        ),
      ),
    );
  }

  // ============================================
  // V4: CYBERPUNK
  // Zero border radius (angular), neon strokes (0.5-2px bright),
  // dark overlays, motion blur, scanline effects
  // ============================================
  static ThemeData _buildCyberpunk(bool isLight, DesignConfig config) {
    final neonOrange = const Color(0xFFFF6B00);
    final neonBlue = const Color(0xFF00D4FF);
    final darkBase = const Color(0xFF0A0A0F);

    final scheme = isLight
        ? ColorScheme.fromSeed(
            seedColor: neonOrange,
            brightness: Brightness.light,
          ).copyWith(
            primary: neonOrange,
            secondary: neonBlue,
            surface: const Color(0xFF1A1A2E),
            error: const Color(0xFFFF0844),
          )
        : ColorScheme.fromSeed(
            seedColor: neonOrange,
            brightness: Brightness.dark,
          ).copyWith(
            primary: neonOrange,
            secondary: neonBlue,
            surface: const Color(0xFF0F0F1A),
            error: const Color(0xFFFF0844),
          );

    final textTheme = _textTheme(
      const Color(0xFFE0E0FF),
      const Color(0xFF8888AA),
      config,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkBase,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE0E0FF),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface.withValues(alpha: config.opacity),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
          side: BorderSide(
            color: neonOrange.withValues(alpha: 0.6),
            width: config.borderWidth,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: neonOrange,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
            side: BorderSide(color: neonOrange, width: config.borderWidth),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: config.letterSpacing,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: neonBlue, width: config.borderWidth),
          foregroundColor: neonBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: config.letterSpacing,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBase.withValues(alpha: 0.8),
        labelStyle: TextStyle(
          color: neonBlue,
          fontWeight: FontWeight.w600,
          letterSpacing: config.letterSpacing,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: neonBlue.withValues(alpha: 0.5),
            width: config.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: neonBlue.withValues(alpha: 0.5),
            width: config.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: neonOrange,
            width: config.borderWidth + 0.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBase.withValues(alpha: 0.95),
        elevation: 0,
        indicatorColor: neonOrange.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: config.letterSpacing,
            color: states.contains(WidgetState.selected)
                ? neonOrange
                : const Color(0xFF8888AA),
          ),
        ),
      ),
    );
  }

  // ============================================
  // V5: LUXURY
  // 24px smooth borders, elevation shadows (12-20px depth),
  // gold accents on primary, serif typography option, dark backgrounds
  // ============================================
  static ThemeData _buildLuxury(bool isLight, DesignConfig config) {
    final goldPrimary = const Color(0xFFD4AF37);
    final goldLight = const Color(0xFFE8C967);
    final richDark = const Color(0xFF1A1614);
    final creamLight = const Color(0xFFFAF8F5);

    final scheme = isLight
        ? ColorScheme.fromSeed(
            seedColor: goldPrimary,
            brightness: Brightness.light,
          ).copyWith(
            primary: goldPrimary,
            secondary: _accentOrange,
            surface: creamLight,
            error: const Color(0xFF9B2C2C),
          )
        : ColorScheme.fromSeed(
            seedColor: goldPrimary,
            brightness: Brightness.dark,
          ).copyWith(
            primary: goldLight,
            secondary: const Color(0xFFF4A142),
            surface: const Color(0xFF252220),
            error: const Color(0xFFFC8181),
          );

    final textTheme = _textTheme(
      isLight ? const Color(0xFF1A1614) : const Color(0xFFF5F0EB),
      isLight ? const Color(0xFF6B5D52) : const Color(0xFFADA49B),
      config,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? creamLight : richDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isLight
            ? const Color(0xFF1A1614)
            : const Color(0xFFF5F0EB),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: config.elevation,
        shadowColor: (isLight ? Colors.black : goldPrimary).withValues(
          alpha: 0.15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
          side: BorderSide(
            color: goldPrimary.withValues(alpha: 0.2),
            width: config.borderWidth,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: isLight ? richDark : richDark,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: config.letterSpacing,
          ),
          elevation: config.elevation / 2,
          shadowColor: goldPrimary.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(
            color: goldPrimary.withValues(alpha: 0.5),
            width: config.borderWidth,
          ),
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: config.letterSpacing,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : const Color(0xFF2A2623),
        labelStyle: TextStyle(
          color: isLight ? const Color(0xFF6B5D52) : const Color(0xFFADA49B),
          fontWeight: FontWeight.w600,
          letterSpacing: config.letterSpacing,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: goldPrimary.withValues(alpha: 0.3),
            width: config.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: goldPrimary.withValues(alpha: 0.3),
            width: config.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.inputBorderRadius),
          borderSide: BorderSide(
            color: goldPrimary,
            width: config.borderWidth + 0.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? creamLight : richDark,
        elevation: config.elevation,
        indicatorColor: goldPrimary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            letterSpacing: config.letterSpacing,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : (isLight ? const Color(0xFF6B5D52) : const Color(0xFFADA49B)),
          ),
        ),
      ),
    );
  }

  // ============================================
  // TEXT THEME BUILDER
  // ============================================
  static TextTheme _textTheme(Color main, Color muted, DesignConfig config) {
    return TextTheme(
      headlineMedium: TextStyle(
        color: main,
        fontSize: 27,
        fontWeight: FontWeight.w800,
        height: 1.12,
        letterSpacing: config.letterSpacing,
      ),
      titleLarge: TextStyle(
        color: main,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: config.letterSpacing * 0.5,
      ),
      titleMedium: TextStyle(
        color: main,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: config.letterSpacing * 0.25,
      ),
      bodyMedium: TextStyle(
        color: muted,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        color: muted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
    );
  }
}