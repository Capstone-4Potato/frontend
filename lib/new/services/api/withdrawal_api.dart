import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:http/http.dart' as http;

/// POST /users/withdrawal  (사용자 계정 탈퇴 사유)
Future<void> sendWithdrawalReason(int reasonCode, String detail) async {
  String? token = await getAccessToken();
  var url = Uri.parse('$main_url/users/withdrawal');
  debugPrint("계정 탈퇴: $reasonCode, $detail");

  // Function to make the get request
  Future<http.Response> makePostRequest(String token) {
    return http.post(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'reasonCode': reasonCode,
        'details': detail,
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
        // Retry the get request with the new token
        token = await getAccessToken();
        response = await makePostRequest(token!);

        if (response.statusCode == 200) {
          debugPrint(response.body);
        } else {
          throw Exception('Failed to fetch user data after refreshing token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } else {
      throw Exception('Failed to fetch user data');
    }
  } catch (e) {
    debugPrint('Network error occurred: $e');
  }
}
