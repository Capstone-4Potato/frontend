import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:http/http.dart' as http;

/// 앱 로그아웃 API
Future<void> logoutRequest() async {
  String? token = await getAccessToken();
  var url = Uri.parse('$main_url/logout');

  // Function to make the signout request
  Future<http.Response> makeLogoutRequest(String token) {
    return http.post(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      },
    );
  }

  try {
    var response = await makeLogoutRequest(token!);

    if (response.statusCode == 200) {
      deleteTokens();
      print(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the signout request with the new token
        token = await getAccessToken();
        response = await makeLogoutRequest(token!);

        if (response.statusCode == 200) {
          deleteTokens();
          print(response.body);
        } else {
          throw Exception('Failed to sign out after refreshing token');
        }
      } else {
        throw Exception('Failed to refresh access token');
      }
    } else {
      throw Exception('Failed to sign out');
    }
  } catch (e) {
    // Handle errors that occur during the request
    print("Error sign out: $e");
  }
}
