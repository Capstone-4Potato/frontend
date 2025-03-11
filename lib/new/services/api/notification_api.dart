import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### POST `notification/{notificationId}` : 알림 읽음 처리
/// 특정 알림을 읽음 처리합니다.
Future<int> postNotificationRead(int notificationId) async {
  try {
    int resultCode = 500; // Default error code

    await apiRequest(
      endpoint: 'notification/$notificationId',
      method: ApiMethod.post.type,
      onSuccess: (response) {
        resultCode = response.statusCode;
      },
      onError: (statusCode, errorBody) {
        resultCode = statusCode;
      },
    );

    return resultCode;
  } catch (e) {
    debugPrint('알림 읽음 처리 실패 : $e');
    return 500;
  }
}

/// ### POST `notification` : 알림 목록 조회
/// 알림을 반환한다.
Future<List<Map<String, dynamic>>> getNotificationList() async {
  try {
    List<Map<String, dynamic>> result = [];
    await apiRequest(
      endpoint: 'notification',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        result = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      },
    );
    return result;
  } catch (e) {
    debugPrint('알림 읽음 처리 실패 : $e');
    return [];
  }
}
