import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/login_platform.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

// 소셜로그인 로그아웃하기
class SignOutService {
  static Future<void> signOut(LoginPlatform loginPlatform) async {
    switch (loginPlatform) {
      case LoginPlatform.google:
        final GoogleSignIn googleSignIn = GoogleSignIn();
        try {
          await googleSignIn.signOut();
          debugPrint('구글 로그아웃 성공');
        } catch (error) {
          debugPrint('구글 로그아웃 실패: $error');
        }

        break;
      case LoginPlatform.kakao:
        await UserApi.instance.logout();
        print('kakaologout');
        break;

      case LoginPlatform.apple:
        // Add Apple sign-out logic here
        //await FlutterNaverLogin.logOut();
        //print('naverlogout');
        break;
      case LoginPlatform.none:
        break;
    }
  }
}
