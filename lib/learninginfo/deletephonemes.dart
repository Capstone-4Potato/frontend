import 'dart:convert';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

// 전체 취약음 삭제
Future<void> deleteAllPhonemes() async {
  try {
    var url = Uri.parse('$main_url/test/all/phonemes');
    String? token = await getAccessToken();

    // Function to make the delete request
    Future<http.Response> makeDeleteRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      return http.delete(url, headers: headers);
    }

    var response = await makeDeleteRequest(token!);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
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
          var data = json.decode(response.body);
          print(data);
        } else {
          throw Exception('Failed to delete phonemes after refreshing token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } else {
      throw Exception('Failed to delete phonemes');
    }
  } catch (e) {
    print(e);
  }
}
