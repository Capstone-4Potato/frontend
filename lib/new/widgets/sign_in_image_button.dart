import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_application_1/new/models/login_platform.dart';
import 'package:flutter_application_1/new/services/social_login_manage.dart';
import 'package:flutter_application_1/signup/signup_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 소셜로그인 버튼
class SignInImageButton extends StatelessWidget {
  LoginPlatform loginPlatform;

  SignInImageButton({
    Key? key,
    required this.loginPlatform,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// 버튼 눌렀을 때 로그인 처리 함수
    void handleLogin() async {
      // 플랫폼 별 로그인 함수 지정
      final loginActions = {
        LoginPlatform.kakao: signInWithKakao,
        LoginPlatform.google: signInWithGoogle,
        LoginPlatform.apple: signInWithApple,
      };

      // 선택된 로그인 플랫폼 실행
      var result = await (loginActions[loginPlatform] ??
          () async => {})(); // 로그인 실패 시 종료

      debugPrint("$result");

      int statusCode = result['statusCode'];
      String socialId = result['socialId'];

      if (statusCode == 404) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserInputForm(socialId: socialId)),
        );
      } else if (statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeNav()),
          (route) => false,
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: 25.0.h, right: 25.0.h, top: 21.0.h),
      child: InkWell(
        onTap: handleLogin,
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
                  size: 20,
                  color: loginPlatform.textColor,
                ),
                SizedBox(width: 15.w),
                Text(
                  'Continue with ${loginPlatform.platformName}',
                  style: TextStyle(
                    color: loginPlatform.textColor,
                    fontFamily: FontFamily.bmJua.fontName,
                    fontSize: 18,
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
