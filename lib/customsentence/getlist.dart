import 'dart:convert';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>?> fetchCustomList() async {
  try {
    String? token = await getAccessToken();

    var url = Uri.parse('http://potato.seatnullnull.com/cards/custom');

    // Set headers with the token
    var headers = <String, String>{
      'access': '$token',
      'Content-Type': 'application/json',
    };

    var response = await http.get(url, headers: headers);
    print(response.statusCode);

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['cardList'];

      return data;
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh and retry the request
      print('Access token expired. Refreshing token...');

      // Refresh the token
      bool isRefreshed = await refreshAccessToken();

      if (isRefreshed) {
        // Retry request with new token
        print('Token refreshed successfully. Retrying request...');
        String? newToken = await getAccessToken();
        response = await http.get(url, headers: {
          'access': '$newToken',
          'Content-Type': 'application/json'
        });

        if (response.statusCode == 200) {
          var data = json.decode(response.body)['cardList'];
          return data;
        } else {
          // Handle other response codes after retry if needed
          print(
              'Unhandled server response after retry: ${response.statusCode}');
          print(json.decode(response.body));
          return null;
        }
      } else {
        print('Failed to refresh token. Please log in again.');
        return null;
      }
    } else {
      // Handle other status codes
      print('Unhandled server response: ${response.statusCode}');
      print(json.decode(response.body));
      return null;
    }
  } catch (e) {
    // Handle network request exceptions
    print("Error during the request: $e");
    return null;
  }
}
