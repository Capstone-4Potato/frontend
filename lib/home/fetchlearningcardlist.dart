import 'dart:convert';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

// Asynchronously fetch data from the backend
Future<List<dynamic>?> fetchData(String category, String subcategory) async {
  try {
    String? token = await getAccessToken();
    // Backend server URL
    var url = Uri.parse(
        'http://potato.seatnullnull.com/cards?category=${Uri.encodeComponent(category)}&subcategory=${Uri.encodeComponent(subcategory)}');

    // Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
        'Accept-Encoding': 'gzip',
      };
      return http.get(url, headers: headers);
    }

    var response = await makeRequest(token!);

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['cardList'];
      // Return the data if you need to use it after calling fetchData
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
          var data = json.decode(response.body)['cardList'];
          return data;
        }
      }
    }
  } catch (e) {
    print(e);
  }
  return null; // Return null if there's an error or unsuccessful fetch
}
