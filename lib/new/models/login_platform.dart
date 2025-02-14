import 'package:flutter/material.dart';

import 'package:flutter_application_1/icons/login_icons.dart';
import 'package:flutter_application_1/new/models/colors.dart';

/// 로그인 플랫폼
enum LoginPlatform {
  google(
    platformName: 'Google',
    buttonColor: AppColors.white,
    textColor: AppColors.brown,
    borderColor: Color(0xFFE2E2E2),
    icon: LoginIcons.google_icon,
  ),
  kakao(
    platformName: 'Kakao',
    buttonColor: AppColors.yellow,
    textColor: AppColors.brown,
    borderColor: Color(0xFFF3E69E),
    icon: LoginIcons.kakaotalk_icon,
  ),
  apple(
    platformName: 'Apple',
    buttonColor: AppColors.black,
    textColor: AppColors.white,
    borderColor: Color(0xFFE2E2E2),
    icon: LoginIcons.apple_logo,
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
