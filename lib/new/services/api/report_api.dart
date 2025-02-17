import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:http/http.dart' as http;

/// POST /report/cardLevel (사용자 카드 레벨 설정)
Future<void> updateCardLevel(String level) async {
  String? token = await getAccessToken();
  var url = Uri.parse('$main_url/report/cardLevel');
  debugPrint("카드 레벨 설정 : $level");

  // Function to make the delete request
  Future<http.Response> makePostRequest(String token) {
    return http.post(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'level': level,
      }),
    );
  }

  try {
    var response = await makePostRequest(token!);

    if (response.statusCode == 200) {
      debugPrint(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      debugPrint('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the delete request with the new token
        token = await getAccessToken();
        response = await makePostRequest(token!);

        if (response.statusCode == 200) {
          debugPrint(response.body);
        } else {
          throw Exception('Failed to delete account after refreshing token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } else {
      throw Exception('Failed to delete account');
    }
  } catch (e) {
    // Handle errors that occur during the request
    debugPrint("Error deleting account: $e");
  }
}

/// GET /report (My report 화면 정보 조회)
// TODO : report 함수 정의
Future<void> getReportData() async {}
