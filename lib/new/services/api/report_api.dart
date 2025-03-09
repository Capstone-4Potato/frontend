import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

///### POST `report/cardLevel` : 사용자 카드 레벨 설정
Future<void> updateCardLevelRequest(String level) async {
  try {
    await apiRequest(
        endpoint: 'report/cardLevel',
        method: ApiMethod.post.type,
        body: {
          'level': level,
        });
  } catch (e) {
    debugPrint('회원 카드 레벨 설정 실패 : $e');
  }
}

/// ### GET `/report` : My report 화면 정보 조회
Future<void> getReportDataRequest({
  required Function(Map<String, dynamic>) onDataReceived,
}) async {
  try {
    await apiRequest(
      endpoint: 'report',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        final data = jsonDecode(response.body);
        onDataReceived(data);
      },
    );
  } catch (e) {
    debugPrint('report 화면 정보 조회 실패 : $e');
  }
}
