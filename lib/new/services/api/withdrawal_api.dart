import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### POST `/users/withdrawal` : 사용자 계정 탈퇴 사유
Future<void> sendWithdrawalReasonRequest(int reasonCode, String detail) async {
  try {
    await apiRequest(
        endpoint: 'users/withdrawal',
        method: ApiMethod.post.type,
        requiresAuth: true,
        body: {
          'reasonCode': reasonCode,
          'details': detail,
        },
        onSuccess: (response) {});
  } catch (e) {
    debugPrint("로그아웃 Error: $e");
  }
}
