import 'dart:convert';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/models/user_info.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:http/http.dart' as http;

/// DELETE /users  (회원 탈퇴 )
Future<void> deleteUsersAccountRequest(String nickname) async {
  String? token = await getAccessToken();
  var url = Uri.parse('$main_url/users');

  // Function to make the delete request
  Future<http.Response> makeDeleteRequest(String token) {
    return http.delete(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'name': nickname,
      }),
    );
  }

  try {
    var response = await makeDeleteRequest(token!);

    if (response.statusCode == 200) {
      deleteTokens();
      print(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the delete request with the new token
        token = await getAccessToken();
        response = await makeDeleteRequest(token!);

        if (response.statusCode == 200) {
          deleteTokens();
          print(response.body);
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
    print("Error deleting account: $e");
  }
}

/// PATCH /users  (회원정보 수정)
Future<http.Response> updateUserDataRequest(String token) async {
  final userInfo = UserInfo();
  await userInfo.loadUserInfo(); // 유저 정보 로드

  var url = Uri.parse('$main_url/users');

  return await http.patch(
    url,
    headers: <String, String>{
      'access': token,
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'name': userInfo.name,
      'age': userInfo.age,
      'gender': userInfo.gender,
    }),
  );
}
