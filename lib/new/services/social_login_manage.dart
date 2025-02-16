import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/models/login_platform.dart';
import 'package:flutter_application_1/new/services/login_platform_manage.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';

/// 소셜로그인 API 요청
Future<int> sendSocialLoginRequest(String? socialId) async {
  var url = Uri.parse('$main_url/login');

  try {
    var request = http.MultipartRequest('POST', url);
    request.fields['socialId'] = socialId!;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    debugPrint("응답 : ${response.body}");

    if (response.statusCode == 200) {
      // Assuming 'access' is the key for the access token in headers
      String? accessToken = response.headers['access'];
      String? refreshToken = response.headers['refresh'];

      if (accessToken != null && refreshToken != null) {
        await saveTokens(accessToken, refreshToken);
      }
    }

    return response.statusCode; // Return the status code
  } catch (e) {
    debugPrint('Network error occurred: $e');
    return 500; // Assume server error on exception
  }
}

/// 애플 로그인
Future<Map<String, dynamic>> signInWithApple() async {
  try {
    final AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ],
    );

    int statusCode = await sendSocialLoginRequest(credential.userIdentifier);

    if (statusCode == 200 || statusCode == 404) {
      await saveLoginPlatform(LoginPlatform.apple);
    }
    return {
      'statusCode': statusCode,
      'socialId': credential.userIdentifier,
    };
  } catch (error) {
    debugPrint('error = $error');
    return {
      'statusCode': 500,
      'socialId': '',
    };
  }
}

/// 카카오 로그인
Future<Map<String, dynamic>> signInWithKakao() async {
  if (await isKakaoTalkInstalled()) {
    try {
      await UserApi.instance.loginWithKakaoTalk();
      debugPrint('카카오톡으로 로그인 성공');
      User user = await UserApi.instance.me();
      debugPrint('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}');

      // 소셜 로그인 정보 전달
      int statusCode = await sendSocialLoginRequest(user.id.toString());
      if (statusCode == 200 || statusCode == 404) {
        await saveLoginPlatform(LoginPlatform.kakao);
      }
      return {
        'statusCode': statusCode,
        'socialId': user.id.toString(),
      };
    } catch (error) {
      debugPrint('카카오톡으로 로그인 실패 $error');

      if (error is PlatformException && error.code == 'CANCELED') {
        debugPrint('로그인 취소');
        return {
          'statusCode': 500,
          'socialId': '',
        };
      }
      try {
        await UserApi.instance.loginWithKakaoAccount();
        debugPrint('카카오계정으로 로그인 성공');
        User user = await UserApi.instance.me();
        debugPrint('사용자 정보 요청 성공'
            '\n회원번호: ${user.id}');
        int statusCode = await sendSocialLoginRequest(user.id.toString());
        if (statusCode == 200 || statusCode == 404) {
          await saveLoginPlatform(LoginPlatform.kakao);
        }
        return {
          'statusCode': statusCode,
          'socialId': user.id.toString(),
        };
      } catch (error) {
        debugPrint('카카오계정으로 로그인 실패 $error');
        return {
          'statusCode': 500,
          'socialId': '',
        }; //
      }
    }
  } else {
    try {
      await UserApi.instance.loginWithKakaoAccount();
      debugPrint('카카오계정으로 로그인 성공');
      User user = await UserApi.instance.me();
      debugPrint('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}');
      int statusCode = await sendSocialLoginRequest(user.id.toString());
      if (statusCode == 200 || statusCode == 404) {
        await saveLoginPlatform(LoginPlatform.kakao);
      }
      return {
        'statusCode': statusCode,
        'socialId': user.id.toString(),
      };
    } catch (error) {
      print('카카오계정으로 로그인 실패 $error');
      return {
        'statusCode': 500,
        'socialId': '',
      }; //
    }
  }
}

/// 구글 로그인
Future<Map<String, dynamic>> signInWithGoogle() async {
  try {
    debugPrint('try');
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    debugPrint('구글 계정으로 로그인!');
    if (googleUser != null) {
      debugPrint('name = ${googleUser.displayName}\n');
      debugPrint('name = ${googleUser.email}\n');
      debugPrint('name = ${googleUser.id}\n');

      int statusCode = await sendSocialLoginRequest(googleUser.id.toString());
      if (statusCode == 200 || statusCode == 404) {
        await saveLoginPlatform(LoginPlatform.google);
      }
      return {
        'statusCode': statusCode,
        'socialId': googleUser.id,
      };
    } else {
      return {
        'statusCode': 500,
        'socialId': '',
      };
    }
  } catch (error) {
    debugPrint('구글계정으로 로그인 실패 $error');
    return {
      'statusCode': 500,
      'socialId': '',
    }; //
  }
}
