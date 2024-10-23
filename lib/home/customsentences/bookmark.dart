import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

// 맞춤 문장 북마크 API
Future<void> updateCustomBookmark(int cardId, bool newStatus) async {
  // 토큰을 가져오는 함수를 별도 메서드로 분리
  Future<String?> fetchAccessToken() async {
    return await getAccessToken();
  }

  // 요청을 보내는 함수를 별도 메서드로 분리
  Future<http.Response> makeRequest(String token) async {
    var url = Uri.parse('$main_url/bookmark/$cardId');
    return await http.get(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  // 요청을 보낼 때 사용할 액세스 토큰
  String? token = await fetchAccessToken();
  var response = await makeRequest(token!);

  if (response.statusCode == 200) {
    // OK : 북마크 UPDATE(있으면 삭제 없으면 추가)
    print('Bookmark updated successfully: ${response.body}');
  } else if (response.statusCode == 401) {
    // 토큰이 만료된 경우
    print('Access token expired. Refreshing token...');

    // 리프레시 토큰을 사용하여 새로운 액세스 토큰을 가져옵니다.
    bool isRefreshed = await refreshAccessToken();

    if (isRefreshed) {
      // 새로운 액세스 토큰으로 다시 시도
      print('Token refreshed successfully. Retrying request...');
      String? newToken = await fetchAccessToken();
      response = await makeRequest(newToken!);

      if (response.statusCode == 200) {
        print(
            'Bookmark updated successfully after refreshing token: ${response.body}');
      } else {
        print(
            'Failed to update bookmark after refreshing token: ${response.statusCode}');
      }
    } else {
      print('Failed to refresh token. Please log in again.');
    }
  } else {
    // 다른 상태 코드에 대한 처리
    print('Failed to update bookmark. Status code: ${response.statusCode}');
  }
}
