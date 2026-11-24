import 'package:material_ui/material_ui.dart';

/// Semantic color tokens sampled directly from the GotaSolidária Figma prototype.
class AppColors {
  AppColors._();

  // Brand & Primary
  static const Color primary = Color(0xFFC62828);
  static const Color primaryDeep = Color(0xFF8E1717);
  static const Color primaryDarkMode = Color(0xFFD93838);

  // Soft Rose / Pink Surfaces (Light)
  static const Color roseSurface = Color(0xFFFFEBEE);
  static const Color avatarRose = Color(0xFFFFCDD2);
  static const Color roseBorder = Color(0xFFF7D2D5);

  // Success / Mint Green
  static const Color success = Color(0xFF2E7D32);
  static const Color mintSurface = Color(0xFFE7F4E8);
  static const Color whatsAppGreen = Color(0xFF168C4A);

  // Critical Stock Warning Amber
  static const Color warningSurface = Color(0xFFFFF1D6);
  static const Color warningIconBg = Color(0xFFFDE0AA);
  static const Color warningBorder = Color(0xFFE2B973);
  static const Color warningTitle = Color(0xFF8A4B08);

  // Light Mode Neutrals
  static const Color lightBackground = Color(0xFFF8F6F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD7D1D0);
  static const Color lightDivider = Color(0xFFECE8E6);
  static const Color lightTextPrimary = Color(0xFF1C1B1F);
  static const Color lightTextSecondary = Color(0xFF625B60);
  static const Color lightTextMuted = Color(0xFF8C8589);
  static const Color switchOffTrack = Color(0xFF8A8387);

  // Dark Mode Neutrals (harmonized with Page 11 dark campaign surface)
  static const Color darkBackground = Color(0xFF0E1117);
  static const Color darkSurface = Color(0xFF171B24);
  static const Color darkSurfaceElevated = Color(0xFF1F2430);
  static const Color darkBorder = Color(0xFF2D3342);
  static const Color darkDivider = Color(0xFF252A36);
  static const Color darkTextPrimary = Color(0xFFF5F3F1);
  static const Color darkTextSecondary = Color(0xFFABA4A9);
  static const Color darkTextMuted = Color(0xFF7D777C);
  static const Color darkRoseSurface = Color(0xFF3A1B1E);
  static const Color darkAvatarRose = Color(0xFF4D2327);
  static const Color darkMintSurface = Color(0xFF183320);
  static const Color darkWarningSurface = Color(0xFF332612);
  static const Color darkWarningIconBg = Color(0xFF4A3617);
  static const Color darkWarningBorder = Color(0xFF855D1C);
  static const Color darkWarningTitle = Color(0xFFFBD38D);

  // Custom Keyboard Tokens (Pages 8 & 9)
  static const Color keyboardBackground = Color(0xFFD1D4DA);
  static const Color keyboardSpecialKey = Color(0xFFAEB3BC);
  static const Color keyboardKey = Color(0xFFFFFFFF);
  static const Color darkKeyboardBackground = Color(0xFF1C1F26);
  static const Color darkKeyboardSpecialKey = Color(0xFF343A46);
  static const Color darkKeyboardKey = Color(0xFF2B303B);
}

@immutable
class GotaColors extends ThemeExtension<GotaColors> {
  const GotaColors({
    required this.background,
    required this.surface,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primaryDeep,
    required this.roseSurface,
    required this.avatarRose,
    required this.roseBorder,
    required this.success,
    required this.mintSurface,
    required this.warningSurface,
    required this.warningIconBg,
    required this.warningBorder,
    required this.warningTitle,
    required this.keyboardBg,
    required this.keyboardKey,
    required this.keyboardSpecialKey,
  });

  final Color background;
  final Color surface;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color primaryDeep;
  final Color roseSurface;
  final Color avatarRose;
  final Color roseBorder;
  final Color success;
  final Color mintSurface;
  final Color warningSurface;
  final Color warningIconBg;
  final Color warningBorder;
  final Color warningTitle;
  final Color keyboardBg;
  final Color keyboardKey;
  final Color keyboardSpecialKey;

  static const GotaColors light = GotaColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    primary: AppColors.primary,
    primaryDeep: AppColors.primaryDeep,
    roseSurface: AppColors.roseSurface,
    avatarRose: AppColors.avatarRose,
    roseBorder: AppColors.roseBorder,
    success: AppColors.success,
    mintSurface: AppColors.mintSurface,
    warningSurface: AppColors.warningSurface,
    warningIconBg: AppColors.warningIconBg,
    warningBorder: AppColors.warningBorder,
    warningTitle: AppColors.warningTitle,
    keyboardBg: AppColors.keyboardBackground,
    keyboardKey: AppColors.keyboardKey,
    keyboardSpecialKey: AppColors.keyboardSpecialKey,
  );

  static const GotaColors dark = GotaColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    border: AppColors.darkBorder,
    divider: AppColors.darkDivider,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    primary: AppColors.primaryDarkMode,
    primaryDeep: Color(0xFFFF8A80),
    roseSurface: AppColors.darkRoseSurface,
    avatarRose: AppColors.darkAvatarRose,
    roseBorder: Color(0xFF5A252A),
    success: Color(0xFF4CAF50),
    mintSurface: AppColors.darkMintSurface,
    warningSurface: AppColors.darkWarningSurface,
    warningIconBg: AppColors.darkWarningIconBg,
    warningBorder: AppColors.darkWarningBorder,
    warningTitle: AppColors.darkWarningTitle,
    keyboardBg: AppColors.darkKeyboardBackground,
    keyboardKey: AppColors.darkKeyboardKey,
    keyboardSpecialKey: AppColors.darkKeyboardSpecialKey,
  );

  @override
  GotaColors copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? primaryDeep,
    Color? roseSurface,
    Color? avatarRose,
    Color? roseBorder,
    Color? success,
    Color? mintSurface,
    Color? warningSurface,
    Color? warningIconBg,
    Color? warningBorder,
    Color? warningTitle,
    Color? keyboardBg,
    Color? keyboardKey,
    Color? keyboardSpecialKey,
  }) {
    return GotaColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      roseSurface: roseSurface ?? this.roseSurface,
      avatarRose: avatarRose ?? this.avatarRose,
      roseBorder: roseBorder ?? this.roseBorder,
      success: success ?? this.success,
      mintSurface: mintSurface ?? this.mintSurface,
      warningSurface: warningSurface ?? this.warningSurface,
      warningIconBg: warningIconBg ?? this.warningIconBg,
      warningBorder: warningBorder ?? this.warningBorder,
      warningTitle: warningTitle ?? this.warningTitle,
      keyboardBg: keyboardBg ?? this.keyboardBg,
      keyboardKey: keyboardKey ?? this.keyboardKey,
      keyboardSpecialKey: keyboardSpecialKey ?? this.keyboardSpecialKey,
    );
  }

  @override
  GotaColors lerp(ThemeExtension<GotaColors>? other, double t) {
    if (other is! GotaColors) return this;
    return GotaColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      roseSurface: Color.lerp(roseSurface, other.roseSurface, t)!,
      avatarRose: Color.lerp(avatarRose, other.avatarRose, t)!,
      roseBorder: Color.lerp(roseBorder, other.roseBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      mintSurface: Color.lerp(mintSurface, other.mintSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      warningIconBg: Color.lerp(warningIconBg, other.warningIconBg, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      warningTitle: Color.lerp(warningTitle, other.warningTitle, t)!,
      keyboardBg: Color.lerp(keyboardBg, other.keyboardBg, t)!,
      keyboardKey: Color.lerp(keyboardKey, other.keyboardKey, t)!,
      keyboardSpecialKey:
          Color.lerp(keyboardSpecialKey, other.keyboardSpecialKey, t)!,
    );
  }
}

extension GotaThemeContext on BuildContext {
  GotaColors get gotaColors =>
      Theme.of(this).extension<GotaColors>() ?? GotaColors.light;
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.success,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      dividerColor: AppColors.lightDivider,
    );

    return base.copyWith(
      extensions: const <ThemeExtension<dynamic>>[GotaColors.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDarkMode,
        onPrimary: Colors.white,
        secondary: Color(0xFF4CAF50),
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.primaryDarkMode,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      dividerColor: AppColors.darkDivider,
    );

    return base.copyWith(
      extensions: const <ThemeExtension<dynamic>>[GotaColors.dark],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle:
            const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
