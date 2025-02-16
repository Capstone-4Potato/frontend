import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:http/http.dart' as http;

// 취약음테스트 테스트 완료 API
Future<int> testfinalize() async {
  try {
    String? token = await getAccessToken();
    var url = Uri.parse('$main_url/test/finalize');
// Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      return http.post(url, headers: headers);
    }

    var response = await makeRequest(token!);
    print(response.body);
    if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');
      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the request with the new token
        token = await getAccessToken();
        response = await makeRequest(token!);
        return response.statusCode;
      }
    }
    return response.statusCode;
  } catch (e) {
    // 요청 중에 발생한 에러 처리
    print("Error sign out: $e");
    return 500;
  }
}
