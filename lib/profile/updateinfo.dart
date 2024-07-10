import 'dart:convert';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

Future<void> updateInfo({String? nickname, int? age, int? gender}) async {
  String? token = await getAccessToken();
  if (token == null) {
    print("Error: Access token is null");
    return;
  }

  var url = Uri.parse('http://potato.seatnullnull.com/users');

  Map<String, dynamic> body = {};
  if (nickname != null) body['name'] = nickname;
  if (age != null) body['age'] = age;
  if (gender != null) body['gender'] = gender;

  // Function to make the patch request
  Future<http.Response> makePatchRequest(String token) {
    return http.patch(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  try {
    var response = await makePatchRequest(token);

    if (response.statusCode == 200) {
      print("Info updated successfully: ${response.body}");
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the patch request with the new token
        token = await getAccessToken();
        response = await makePatchRequest(token!);

        if (response.statusCode == 200) {
          print("Info updated successfully: ${response.body}");
        } else {
          print(
              "Failed to update info after refreshing token: ${response.statusCode} - ${response.body}");
        }
      } else {
        print('Failed to refresh access token');
      }
    } else {
      print("Failed to update info: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error updating info: $e");
  }
}
