import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/models/navigation_type.dart';
import 'package:flutter_application_1/new/models/user_info.dart';
import 'package:flutter_application_1/new/screens/login_screen.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_application_1/new/services/tutorial_initializer.dart';
import 'package:flutter_application_1/new/utils/navigation_extension.dart';
import 'package:flutter_application_1/widgets/success_dialog.dart';

/// ### DELETE `/users` : 회원 탈퇴
Future<void> deleteUsersAccountRequest(
    String nickname, BuildContext context) async {
  try {
    await apiRequest(
        endpoint: 'users',
        method: ApiMethod.delete.type,
        body: {'name': nickname},
        onSuccess: (response) {
          // 토큰 삭제
          deleteTokens();
          // 튜토 정보 삭제
          initiallizeTutoInfo(false);
          // 로그인 화면으로 이동
          context.navigateTo(
              screen: const LoginScreen(),
              type: NavigationType.pushAndRemoveUntil);
        });
  } catch (e) {
    debugPrint('계정 삭제 실패 : $e');
  }
}

/// ### PATCH `/users` : 회원정보 수정
Future<void> updateUserDataRequest(BuildContext context) async {
  try {
    final userInfo = UserInfo();
    await userInfo.loadUserInfo(); // 유저 정보 로드

    await apiRequest(
        // api 요청
        endpoint: 'users',
        method: ApiMethod.patch.type,
        body: {
          'name': userInfo.name,
          'age': userInfo.age,
          'gender': userInfo.gender,
        },
        onSuccess: (response) {
          // 토큰 삭제
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return SuccessDialog(
                subtitle: 'Your profile has been updated successfully.',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              );
            },
          );
        });
  } catch (e) {
    debugPrint('회원 정보 수정 실패 : $e');
  }
}
