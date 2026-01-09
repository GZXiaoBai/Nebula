import 'package:flutter/material.dart';

/// Nebula 主题配置 - 支持亮/暗模式切换
class NebulaTheme {
  NebulaTheme._();

  // ============================================
  // 颜色定义 - 暗色模式
  // ============================================

  // 背景色 (暗色)
  static const darkBackground = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF252525);
  static const darkCardHover = Color(0xFF2D2D2D);

  // ============================================
  // 颜色定义 - 亮色模式
  // ============================================

  // 背景色 (亮色)
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardHover = Color(0xFFF1F5F9);

  // ============================================
  // 共享颜色 (两种模式通用)
  // ============================================

  // 强调色
  static const primaryStart = Color(0xFF6366F1);
  static const primaryEnd = Color(0xFF8B5CF6);
  static const secondary = Color(0xFFF472B6);

  // 状态色
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // 文字色 (暗色模式)
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkTextMuted = Color(0xFF6B7280);

  // 文字色 (亮色模式)
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextMuted = Color(0xFF94A3B8);

  // 边框 (暗色模式)
  static const darkBorder = Color(0xFF374151);
  static const darkBorderLight = Color(0xFF4B5563);

  // 边框 (亮色模式)
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightBorderLight = Color(0xFFCBD5E1);

  // 侧边栏颜色
  static const sidebarDark = Color(0xFF111111);
  static const sidebarLight = Color(0xFFFFFFFF);

  // ============================================
  // 渐变
  // ============================================

  static const primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const progressGradient = LinearGradient(
    colors: [primaryStart, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // 间距
  // ============================================

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;

  // ============================================
  // 圆角
  // ============================================

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  // ============================================
  // 阴影
  // ============================================

  static List<BoxShadow> get cardShadowDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadowLight => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryStart.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  // ============================================
  // 动画时长
  // ============================================

  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);

  // ============================================
  // 侧边栏尺寸
  // ============================================

  static const double sidebarWidth = 240;
  static const double sidebarCollapsedWidth = 72;

  // ============================================
  // 暗色主题
  // ============================================

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          surface: darkSurface,
          primary: primaryStart,
          secondary: secondary,
          error: error,
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: darkTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: darkTextPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: darkTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: darkTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: darkTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: darkTextSecondary,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: darkTextSecondary,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: darkTextMuted,
            fontSize: 12,
          ),
        ),
        iconTheme: const IconThemeData(
          color: darkTextSecondary,
        ),
        dividerTheme: const DividerThemeData(
          color: darkBorder,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primaryStart, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryStart,
            foregroundColor: darkTextPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLg,
              vertical: spacingMd,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryStart,
          ),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: sidebarDark,
          selectedIconTheme: IconThemeData(color: primaryStart),
          unselectedIconTheme: IconThemeData(color: darkTextMuted),
          selectedLabelTextStyle: TextStyle(
            color: primaryStart,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: darkTextMuted,
          ),
        ),
      );

  // ============================================
  // 亮色主题
  // ============================================

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: const ColorScheme.light(
          surface: lightSurface,
          primary: primaryStart,
          secondary: secondary,
          error: error,
        ),
        cardTheme: CardThemeData(
          color: lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            side: const BorderSide(color: lightBorder, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightSurface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: lightTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: lightTextPrimary),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: lightTextPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: lightTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: lightTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: lightTextSecondary,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: lightTextSecondary,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: lightTextMuted,
            fontSize: 12,
          ),
        ),
        iconTheme: const IconThemeData(
          color: lightTextSecondary,
        ),
        dividerTheme: const DividerThemeData(
          color: lightBorder,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primaryStart, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryStart,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: spacingLg,
              vertical: spacingMd,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryStart,
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: sidebarLight,
          selectedIconTheme: const IconThemeData(color: primaryStart),
          unselectedIconTheme: IconThemeData(color: lightTextMuted),
          selectedLabelTextStyle: const TextStyle(
            color: primaryStart,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: lightTextMuted,
          ),
        ),
      );

  // ============================================
  // 兼容旧代码的别名
  // ============================================

  static const background = darkBackground;
  static const surface = darkSurface;
  static const card = darkCard;
  static const cardHover = darkCardHover;
  static const textPrimary = darkTextPrimary;
  static const textSecondary = darkTextSecondary;
  static const textMuted = darkTextMuted;
  static const border = darkBorder;
  static const borderLight = darkBorderLight;

  static List<BoxShadow> get cardShadow => cardShadowDark;
}

/// 主题扩展 - 用于访问自定义颜色
extension NebulaThemeExtension on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  Color get nebulaBackground =>
      isDark ? NebulaTheme.darkBackground : NebulaTheme.lightBackground;

  Color get nebulaSurface =>
      isDark ? NebulaTheme.darkSurface : NebulaTheme.lightSurface;

  Color get nebulaCard =>
      isDark ? NebulaTheme.darkCard : NebulaTheme.lightCard;

  Color get nebulaCardHover =>
      isDark ? NebulaTheme.darkCardHover : NebulaTheme.lightCardHover;

  Color get nebulaTextPrimary =>
      isDark ? NebulaTheme.darkTextPrimary : NebulaTheme.lightTextPrimary;

  Color get nebulaTextSecondary =>
      isDark ? NebulaTheme.darkTextSecondary : NebulaTheme.lightTextSecondary;

  Color get nebulaTextMuted =>
      isDark ? NebulaTheme.darkTextMuted : NebulaTheme.lightTextMuted;

  Color get nebulaBorder =>
      isDark ? NebulaTheme.darkBorder : NebulaTheme.lightBorder;

  Color get nebulaSidebar =>
      isDark ? NebulaTheme.sidebarDark : NebulaTheme.sidebarLight;

  List<BoxShadow> get nebulaCardShadow =>
      isDark ? NebulaTheme.cardShadowDark : NebulaTheme.cardShadowLight;
}
