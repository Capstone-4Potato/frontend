import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:http/http.dart' as http;

/// ### POST `reissue` : 토큰 재발급
/// 만료된 또는 유효한 refresh 토큰을 이용하여 새로운 access 및 refresh 토큰을 재발급한다.
Future<bool> refreshAccessToken() async {
  String url = '$mainUrl/reissue';
  try {
    String? refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      debugPrint('No refresh token found for user.');
      return false;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {'refresh': refreshToken, "Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final newAccessToken = response.headers['access'];
      final newRefreshToken = response.headers['refresh'];
      debugPrint('$newAccessToken');
      await saveTokens(newAccessToken!, newRefreshToken!);

      debugPrint('토큰 재발급 완료');
      return true;
    }

    // refresh 만료 -> 강제 로그아웃시키기
    else if (response.statusCode == 401) {
      debugPrint('refresh 만료');
      deleteTokens();

      return false;
    }
  } catch (e) {
    debugPrint('Token refresh failed: $e');
  }
  return false;
}
