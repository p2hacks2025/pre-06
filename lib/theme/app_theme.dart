import 'package:flutter/material.dart';

class AppTheme {
  // ===== Brand Colors（指定されたパレット）=====
  static const Color cream = Color(0xFFFFFDEB); // #FFFDEB
  static const Color white = Color(0xFFFFFFFF); // #FFFFFF
  static const Color softPink = Color(0xFFFBD1ED); // #FBD1ED
  static const Color navy = Color(0xFF3E4A79); // #3E4A79

  // ===== 既存コード互換カラー（ここ超重要）=====
  // 画面側で使われている名前を全部定義する
  static const Color terracotta = navy;
  static const Color oliveGreen = softPink;
  static const Color softPeach = softPink;
  static const Color softGray = Color(0xFF9E9E9E);
  static const Color warmBeige = cream;
  static const Color charcoal = Color(0xFF333333);

  // ===== ThemeData =====
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'ZenMaru',

      scaffoldBackgroundColor: cream,
      primaryColor: softPink,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: navy,
        centerTitle: true,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          color: navy,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: navy,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.7, color: navy),
        bodyMedium: TextStyle(fontSize: 14, color: navy),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      dividerColor: softGray.withOpacity(0.2),
    );
  }
}
