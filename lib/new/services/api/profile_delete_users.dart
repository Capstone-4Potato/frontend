import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/models/user_info.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:http/http.dart' as http;

/// 회원정보 받기 API
Future<void> getUsersData() async {
  String? token = await getAccessToken();
  var url = Uri.parse('$main_url/users');

  // Function to make the get request
  Future<http.Response> makeGetRequest(String token) {
    return http.get(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      },
    );
  }

  try {
    var response = await makeGetRequest(token!);

    if (response.statusCode == 200) {
      debugPrint(response.body);
      var data = json.decode(response.body);

      // 사용자 정보 저장
      UserInfo().saveUserInfo(
          name: data['name'],
          age: data['age'],
          gender: data['gender'],
          level: data['level']);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      debugPrint('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the get request with the new token
        token = await getAccessToken();
        response = await makeGetRequest(token!);

        if (response.statusCode == 200) {
          debugPrint(response.body);
          var data = json.decode(response.body);
          UserInfo().saveUserInfo(
              name: data['name'],
              age: data['age'],
              gender: data['gender'],
              level: data['level']);
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

/// 회원가입 탈퇴계정 복구 API
Future<void> restoreAccountRequest(String socialId) async {
  Uri url = Uri.parse('$main_url/users/recover?socialId=$socialId');
  debugPrint("계정 복구 id : $socialId");
  try {
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    switch (response.statusCode) {
      case 200:
        String? accessToken = response.headers['access'];
        String? refreshToken = response.headers['refresh'];
        debugPrint("accessToken: $accessToken");
        debugPrint("refreshToken: $refreshToken");
        if (accessToken != null && refreshToken != null) {
          // 토큰 저장
          await saveTokens(accessToken, refreshToken);
        }
        break;

      case 500:
        debugPrint(response.body);
        break;
      default:
        debugPrint(response.body);
        debugPrint('알 수 없는 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
        // 기타 상태 코드에 대한 처리
        break;
    }
  } catch (e) {
    debugPrint('네트워크 오류가 발생했습니다: $e');
    // 네트워크 예외 처리 로직
  }
}

/// 회원가입 탈퇴계정 삭제 API
Future<void> deleteAccountRequest(String socialId) async {
  Uri url = Uri.parse('$main_url/users/delete?socialId=$socialId');
  try {
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    switch (response.statusCode) {
      case 200:
        debugPrint("사용자 탈퇴 계정 삭제 완료");
        break;

      case 500:
        debugPrint(response.body);
        break;
      default:
        debugPrint('알 수 없는 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
        // 기타 상태 코드에 대한 처리
        break;
    }
  } catch (e) {
    debugPrint('네트워크 오류가 발생했습니다: $e');
    // 네트워크 예외 처리 로직
  }
}

/// 회원탈퇴 API 요청
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
