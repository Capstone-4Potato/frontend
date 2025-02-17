import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_application_1/new/widgets/ask_recover_dialog.dart';
import 'package:http/http.dart' as http;

/// POST /logout  (로그아웃)
Future<void> logoutRequest() async {
  String? token = await getAccessToken();
  var url = Uri.parse('$main_url/logout');

  // Function to make the signout request
  Future<http.Response> makeLogoutRequest(String token) {
    return http.post(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      },
    );
  }

  try {
    var response = await makeLogoutRequest(token!);

    if (response.statusCode == 200) {
      deleteTokens();
      print(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the signout request with the new token
        token = await getAccessToken();
        response = await makeLogoutRequest(token!);

        if (response.statusCode == 200) {
          deleteTokens();
          print(response.body);
        } else {
          throw Exception('Failed to sign out after refreshing token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } else {
      throw Exception('Failed to sign out');
    }
  } catch (e) {
    // Handle errors that occur during the request
    print("Error sign out: $e");
  }
}

/// POST /login  (로그인)
Future<int> sendSocialLoginRequest(
    BuildContext context, String? socialId) async {
  var url = Uri.parse('$main_url/login');

  try {
    var request = http.MultipartRequest('POST', url);
    request.fields['socialId'] = socialId!;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    debugPrint("응답 : ${response.body}");

    if (response.statusCode == 200) {
      // Assuming 'access' is the key for the access token in headers
      String? accessToken = response.headers['access'];
      String? refreshToken = response.headers['refresh'];

      if (accessToken != null && refreshToken != null) {
        await saveTokens(accessToken, refreshToken);
      }
    } else if (response.statusCode == 403) {
      askRecoverDialog(context, socialId);
    }

    return response.statusCode; // Return the status code
  } catch (e) {
    debugPrint('Network error occurred: $e');
    return 500; // Assume server error on exception
  }
}
