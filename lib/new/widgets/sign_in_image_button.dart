// ignore_for_file: use_build_context_synchronously

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_application_1/new/models/login_platform.dart';
import 'package:flutter_application_1/new/models/navigation_type.dart';
import 'package:flutter_application_1/new/services/firestore_listener.dart';
import 'package:flutter_application_1/new/services/social_login_manage.dart';
import 'package:flutter_application_1/new/utils/navigation_extension.dart';
import 'package:flutter_application_1/signup/signup_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 소셜로그인 버튼
class SignInImageButton extends StatelessWidget {
  final LoginPlatform loginPlatform;

  const SignInImageButton({
    Key? key,
    required this.loginPlatform,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// 버튼 눌렀을 때 로그인 처리 함수
    void handleLogin(BuildContext context) async {
      // 플랫폼 별 로그인 함수 지정
      final loginActions = {
        LoginPlatform.kakao: (BuildContext ctx) => signInWithKakao(ctx),
        LoginPlatform.google: (BuildContext ctx) => signInWithGoogle(ctx),
        LoginPlatform.apple: (BuildContext ctx) => signInWithApple(ctx),
      };

      // 선택된 로그인 플랫폼 실행
      var loginFunction =
          loginActions[loginPlatform] ?? (BuildContext ctx) async => {};
      var result = await loginFunction(context); // context 전달

      debugPrint("$result");

      // 사용자 id 저장
      await FirestoreListener().saveDeviceToken();

      int statusCode = result['statusCode'];
      String socialId = result['socialId'];

      if (statusCode == 404) {
        // GA : 회원가입 여부 전달
        FirebaseAnalytics.instance.logSignUp(signUpMethod: loginPlatform.name);
        // 회원가입 폼으로 이동
        context.navigateTo(screen: UserInputForm(socialId: socialId));
      } else if (statusCode == 200) {
        // GA : 로그인 할 때 플랫폼 전달
        FirebaseAnalytics.instance.logLogin(loginMethod: loginPlatform.name);
        // 홈으로 이동
        context.navigateTo(
            screen: HomeNav(), type: NavigationType.pushAndRemoveUntil);
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 21.0.h),
      child: InkWell(
        onTap: () {
          handleLogin(context);
        },
        child: Ink(
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: loginPlatform.buttonColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: loginPlatform.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  loginPlatform.icon,
                  size: 20.h,
                  color: loginPlatform.textColor,
                ),
                SizedBox(width: 15.w),
                Text(
                  'Continue with ${loginPlatform.platformName}',
                  style: TextStyle(
                    color: loginPlatform.textColor,
                    fontFamily: FontFamily.bmJua.fontName,
                    fontSize: 18.h,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
