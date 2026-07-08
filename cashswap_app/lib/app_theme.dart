import 'package:flutter/material.dart';

class AppTheme {
  // Brand palette
  static const Color primary = Color(0xFF00C896);      // Emerald green
  static const Color primaryDark = Color(0xFF00A37A);
  static const Color secondary = Color(0xFF6C63FF);    // Violet
  static const Color cashColor = Color(0xFFFF8C00);    // Amber for cash
  static const Color digitalColor = Color(0xFF00C896); // Green for digital
  static const Color surface = Color(0xFF0F1923);      // Deep navy
  static const Color surfaceAlt = Color(0xFF1A2535);
  static const Color card = Color(0xFF1E2F43);
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8A9DC0);
  static const Color error = Color(0xFFFF4D6A);
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB547);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Sora',
        scaffoldBackgroundColor: surface,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surfaceAlt,
          error: error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textSecondary),
        ),
        cardTheme: CardTheme(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surfaceAlt,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}

// Reusable text styles
class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontFamily: 'Sora',
  );
  static const heading2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontFamily: 'Sora',
  );
  static const body = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textPrimary, fontFamily: 'Sora',
  );
  static const caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.textSecondary, fontFamily: 'Sora',
  );
  static const amount = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primary, fontFamily: 'Sora',
  );
}
