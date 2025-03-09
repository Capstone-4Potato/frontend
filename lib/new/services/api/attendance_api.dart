import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### GET `home/attendance` : 사용자 출석 날짜 조회
/// 사용자의 월별 출석 날짜를 조회합니다.
Future<void> getUserAttendanceRequest({
  required Function(Map<String, dynamic>) onDataReceived,
}) async {
  try {
    await apiRequest(
      endpoint: 'home/attendance',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        final data = jsonDecode(response.body);
        onDataReceived(data);
      },
    );
  } catch (e) {
    debugPrint('사용자 출석 날짜 조회 실패 : $e');
  }
}
