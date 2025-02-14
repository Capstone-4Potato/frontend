import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_application_1/new/models/colors.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_application_1/new/widgets/sign_in_image_button.dart';
import 'package:flutter_application_1/new/models/login_platform.dart';

/// 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 320.h,
              child: Image.asset(
                ImagePath.loginBgText.path,
                width: width,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(flex: 5),
                Container(
                  width: 58.w,
                  height: 58.h,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: AppColors.orange_001,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    ImagePath.loginBalbamCharacter.path,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.brown_001,
                    fontFamily: FontFamily.bmJua.fontName,
                    fontSize: 52.0.h,
                    fontWeight: FontWeight.w400,
                    wordSpacing: 1.2.w,
                  ),
                ),
                Text(
                  'Balbam\nBalbam',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.orange_000,
                      fontFamily: FontFamily.bmJua.fontName,
                      fontSize: 48.0.h,
                      fontWeight: FontWeight.w400,
                      height: 1.2),
                ),
                const Spacer(flex: 5),
                Text(
                  'Log in or sign up to Get Started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.brown_001,
                    fontFamily: FontFamily.bmJua.fontName,
                    fontSize: 18.0.h,
                    fontWeight: FontWeight.w400,
                    wordSpacing: 1.1.w,
                  ),
                ),
                SizedBox(height: 24.h),
                ...[
                  LoginPlatform.apple,
                  LoginPlatform.kakao,
                  LoginPlatform.google,
                ]
                    .map((platform) =>
                        SignInImageButton(loginPlatform: platform))
                    .toList(),
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
