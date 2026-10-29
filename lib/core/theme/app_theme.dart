import 'package:flutter/material.dart';

/// Design system for the Libro de Tareas Soft UI interface.
///
/// All screens use this palette and the same surface treatment so the
/// neumorphic language remains consistent without coupling it to a feature.
class AppTheme {
  AppTheme._();

  static const sky = Color(0xFF8BC9F0);
  static const cyan = Color(0xFFB8EEFF);
  static const pastelBlue = Color(0xFFA6DDF5);
  static const icyWhite = Color(0xFFF0F2FF);
  static const lavender = Color(0xFFE5E9FC);
  static const primary = Color(0xFF4565F5);
  static const secondary = Color(0xFF536CF2);
  static const shadowBlue = Color(0xFF244BAE);
  static const ink = Color(0xFF111522);
  static const muted = Color(0xFF858BA6);
  static const success = Color(0xFF43CB96);
  static const error = Color(0xFFF16F91);
  static const darkBackground = Color(0xFF101A34);
  static const darkSurface = Color(0xFF1A2A4B);

  static const List<Color> categoryPresets = [
    Color(0xFF4565F5),
    Color(0xFFF16F91),
    Color(0xFF43CB96),
    Color(0xFF8B7CF6),
    Color(0xFFFFA66B),
    Color(0xFF58BDEB),
  ];

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      surface: icyWhite,
      onSurface: ink,
      error: error,
    );

    return _baseTheme(
      scheme,
      background: pastelBlue,
      surface: icyWhite,
      textColor: ink,
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF91A4FF),
      secondary: cyan,
      surface: darkSurface,
      onSurface: icyWhite,
      error: error,
    );

    return _baseTheme(
      scheme,
      background: darkBackground,
      surface: darkSurface,
      textColor: icyWhite,
      dark: true,
    );
  }

  static ThemeData _baseTheme(
    ColorScheme scheme, {
    required Color background,
    required Color surface,
    required Color textColor,
    bool dark = false,
  }) {
    final radius = BorderRadius.circular(22);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF21365D) : icyWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(color: dark ? cyan.withValues(alpha: 0.6) : muted),
        labelStyle: TextStyle(color: dark ? cyan : muted),
        prefixIconColor: dark ? cyan : secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.35)),
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? const Color(0xFF21365D) : lavender,
        selectedColor: scheme.primary,
        disabledColor: muted.withValues(alpha: 0.15),
        labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        secondaryLabelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide.none,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? Colors.white12 : shadowBlue.withValues(alpha: 0.12),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFF263D68) : ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor:
            dark ? Colors.white12 : shadowBlue.withValues(alpha: 0.12),
      ),
    );
  }

  static BoxDecoration backgroundDecoration(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const [Color(0xFF17284A), darkBackground]
            : const [Color(0xFFB8EEFF), pastelBlue],
      ),
    );
  }

  static BoxDecoration softDecoration(
    BuildContext context, {
    double radius = 24,
    Color? color,
    bool pressed = false,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = color ?? (dark ? darkSurface : icyWhite);
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: dark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
      ),
      boxShadow: pressed
          ? [
              BoxShadow(
                color:
                    dark ? Colors.black45 : shadowBlue.withValues(alpha: 0.16),
                blurRadius: 9,
                offset: const Offset(4, 5),
              ),
              BoxShadow(
                color: dark
                    ? Colors.white10
                    : Colors.white.withValues(alpha: 0.75),
                blurRadius: 8,
                offset: const Offset(-3, -3),
              ),
            ]
          : [
              BoxShadow(
                color:
                    dark ? Colors.black38 : shadowBlue.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(8, 10),
              ),
              BoxShadow(
                color:
                    dark ? Colors.white10 : Colors.white.withValues(alpha: 0.9),
                blurRadius: 16,
                offset: const Offset(-7, -7),
              ),
            ],
    );
  }
}
