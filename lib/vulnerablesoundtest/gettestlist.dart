import 'dart:convert';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

// 취약음 테스트 리스트 받아오는 API (테스트 새로하기)
Future<List<dynamic>?> getTestNewData() async {
  try {
    var url = Uri.parse('$main_url/test/new');
    String? token = await getAccessToken();

    // Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      return http.post(url, headers: headers);
    }

    var response = await makeRequest(token!);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("import new test data");
      return data;
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the request with the new token
        token = await getAccessToken();
        response = await makeRequest(token!);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          return data;
        }
      }
    }
  } catch (e) {
    print(e);
  }
  return null; // Return null if there's an error or unsuccessful fetch
}

// 취약음 테스트 리스트 받아오는 API (테스트 이어하기)
Future<List<dynamic>?> getTestContinueData() async {
  try {
    var url = Uri.parse('$main_url/test/continue');
    String? token = await getAccessToken();

    // Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      return http.get(url, headers: headers);
    }

    var response = await makeRequest(token!);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("import 기존 test data");
      print(data);
      return data;
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the request with the new token
        token = await getAccessToken();
        response = await makeRequest(token!);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          return data;
        }
      }
    }
  } catch (e) {
    print(e);
  }
  return null; // Return null if there's an error or unsuccessful fetch
}

// 취약음 테스트 확인 함수
Future<bool> getTestCheck() async {
  try {
    var url = Uri.parse('$main_url/test/check');
    String? token = await getAccessToken();

    // Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      return http.get(url, headers: headers);
    }

    var response = await makeRequest(token!);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      return data['hasUnfinishedTest'];
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the request with the new token
        token = await getAccessToken();
        response = await makeRequest(token!);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          return data['hasUnfinishedTest'];
        }
      }
    }
  } catch (e) {
    print(e);
  }
  return false; // Return null if there's an error or unsuccessful fetch
}
