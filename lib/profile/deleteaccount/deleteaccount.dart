import 'dart:convert';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

// 회원탈퇴 API
Future<void> deleteaccount(String nickname) async {
  String? token = await getAccessToken();
  var url = Uri.parse('http://potato.seatnullnull.com/users');

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
