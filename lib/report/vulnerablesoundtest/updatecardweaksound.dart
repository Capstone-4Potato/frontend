import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/api/refresh_access_token.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:http/http.dart' as http;

// 학습 카드에 취약음소 표시 갱신 API
Future<void> updatecardweaksound() async {
  try {
    String? token = await getAccessToken();
    var url = Uri.parse('$mainUrl/cards/weaksound');

    // Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      return http.get(url, headers: headers);
    }

    var response = await makeRequest(token!);
    debugPrint(response.body);

    if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      debugPrint('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the request with the new token
        token = await getAccessToken();
        response = await makeRequest(token!);
        debugPrint(response.body);
      }
    }
  } catch (e) {
    // 요청 중에 발생한 에러 처리
    debugPrint("Error sign out: $e");
  }
}
