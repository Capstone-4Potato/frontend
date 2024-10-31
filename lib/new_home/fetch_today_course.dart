import 'dart:convert';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

// 오늘의 단어 리스트 받아오는 API
Future<List<int>> fetchTodayCourse() async {
  List<int> cardIdList = [];
  try {
    var url = Uri.parse('$main_url/cards/today-course');
    String? token = await getAccessToken();

    // Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      var body = <String, int>{
        'courseSize': 10,
      };
      return http.post(url, headers: headers, body: body);
    }

    var response = await makeRequest(token!);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String cardIds = data['cardIdList'];
      cardIdList = cardIds.split(', ').map(int.parse).toList();

      return cardIdList;
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
  return cardIdList;
}
