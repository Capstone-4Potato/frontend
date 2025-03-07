import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 전체의 테마를 관리하는 클래스
class AppTheme {
  /// 앱의 기본 테마 설정
  static ThemeData get defaultTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: FontFamily.madeTommySoft.fontName,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFEDE8F4),
        primary: AppColors.brown_000,
        onSurface: AppColors.brown_000, // 기본 텍스트 색상 지정
      ),
      textTheme: _buildTextTheme(),
    );
  }

  /// 앱의 텍스트 테마 정의
  static TextTheme _buildTextTheme() {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.brown_000,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.brown_000,
        letterSpacing: 0,
      ),
      bodyMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.brown_000,
        letterSpacing: 0,
      ),
    );
  }
}
