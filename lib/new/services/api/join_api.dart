import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/models/navigation_type.dart';
import 'package:flutter_application_1/new/models/user_info.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_application_1/new/services/tutorial_initializer.dart';
import 'package:flutter_application_1/new/utils/navigation_extension.dart';
import 'package:flutter_application_1/report/vulnerablesoundtest/starting_test_page.dart';

/// ### GET `/users` : 회원정보 조회
Future<void> getUserData(BuildContext context) async {
  try {
    await apiRequest(
        endpoint: 'users',
        method: ApiMethod.get.type,
        onSuccess: (response) {
          final Map<String, dynamic> data = jsonDecode(response.body);

          // 사용자 정보 저장
          UserInfo().saveUserInfo(
              name: data['name'],
              age: data['age'],
              gender: data['gender'],
              level: data['level']);

          // 홈으로 이동
          context.navigateTo(
              screen: HomeNav(), type: NavigationType.pushAndRemoveUntil);
        });
  } catch (e) {
    debugPrint('회원 정보 조회 실패 : $e');
  }
}

/// ### POST `/users` : 회원가입
Future<void> createUserData(BuildContext context, String name, int age,
    int gender, int level, String socialId) async {
  try {
    await apiRequest(
        endpoint: 'users',
        method: ApiMethod.post.type,
        requiresAuth: false, // 인증 필요 없음
        body: {
          'name': name,
          'socialId': socialId,
          'age': age,
          'gender': gender,
          'level': level,
        },
        onSuccess: (response) async {
          // 사용자 정보 저장
          UserInfo()
              .saveUserInfo(name: name, age: age, gender: gender, level: level);

          String? accessToken = response.headers['access'];
          String? refreshToken = response.headers['refresh'];
          if (accessToken != null && refreshToken != null) {
            // 토큰 저장
            await saveTokens(accessToken, refreshToken);
          }

          // tutorial 초기화
          initiallizeTutoInfo(true);

          //튜토리얼로 이동
          // ignore: use_build_context_synchronously
          context.navigateTo(
              screen: const StartTestScreen(),
              type: NavigationType.pushAndRemoveUntil);
        });
  } catch (e) {
    debugPrint('회원 가입 실패 : $e');
  }
}

/// ### POST `/users/recover` : 탈퇴 계정 복구
Future<void> recoverUserAccount(String socialId) async {
  try {
    await apiRequest(
        endpoint: 'users/recover?socialId=$socialId',
        method: ApiMethod.post.type,
        requiresAuth: false, // 인증 필요 없음
        onSuccess: (response) async {
          String? accessToken = response.headers['access'];
          String? refreshToken = response.headers['refresh'];
          if (accessToken != null && refreshToken != null) {
            // 토큰 저장
            await saveTokens(accessToken, refreshToken);
          }
        });
  } catch (e) {
    debugPrint('계정 복구 실패 : $e');
  }
}

/// ### DELETE `/users/delete` : 탈퇴 계정 삭제
Future<void> deleteUserAccount(String socialId) async {
  try {
    await apiRequest(
        endpoint: 'users/delete?socialId=$socialId',
        method: ApiMethod.delete.type,
        requiresAuth: false, // 인증 필요 없음
        onSuccess: (response) async {
          String? accessToken = response.headers['access'];
          String? refreshToken = response.headers['refresh'];
          if (accessToken != null && refreshToken != null) {
            // 토큰 저장
            await saveTokens(accessToken, refreshToken);
          }
        });
  } catch (e) {
    debugPrint('계정 복구 실패 : $e');
  }
}
