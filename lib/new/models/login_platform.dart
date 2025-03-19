import 'package:flutter/material.dart';

import 'package:flutter_application_1/icons/login_icons.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';

/// 로그인 플랫폼
enum LoginPlatform {
  apple(
    platformName: 'Apple',
    buttonColor: AppColors.black,
    textColor: AppColors.white_000,
    borderColor: Color(0xFFE2E2E2),
    icon: LoginIcons.apple_logo,
  ),
  kakao(
    platformName: 'Kakao',
    buttonColor: AppColors.yellow,
    textColor: AppColors.brown_000,
    borderColor: Color(0xFFF3E69E),
    icon: LoginIcons.kakaotalk_icon,
  ),
  google(
    platformName: 'Google',
    buttonColor: AppColors.white_000,
    textColor: AppColors.brown_000,
    borderColor: Color(0xFFE2E2E2),
    icon: LoginIcons.google_icon,
  ),

  none(
    platformName: '',
    buttonColor: Colors.transparent,
    textColor: Colors.transparent,
    borderColor: Colors.transparent,
    icon: Icons.home,
  );

  final String platformName;
  final Color buttonColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;

  const LoginPlatform({
    required this.platformName,
    required this.buttonColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
  });
}
