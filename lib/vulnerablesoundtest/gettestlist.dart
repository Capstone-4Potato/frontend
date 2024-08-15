import 'dart:convert';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

// 취약음 테스트 리스트 받아오는 API
Future<List<dynamic>?> fetchTestData() async {
  try {
    var url = Uri.parse('http://potato.seatnullnull.com/test');
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
