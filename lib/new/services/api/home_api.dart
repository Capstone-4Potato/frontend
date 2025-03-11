import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### GET `home` : 홈 화면 정보 조회
/// 사용자의 홈 화면에 필요한 모든 정보를 반환한다.
Future<Map<String, dynamic>> getHomeDataRequest() async {
  try {
    Map<String, dynamic> result = {};

    result = await apiRequest(
      endpoint: 'home',
      method: ApiMethod.get.type,
    );

    return result;
  } catch (e) {
    debugPrint('홈 화면 정보 조회 실패 : $e');
    return {};
  }
}
