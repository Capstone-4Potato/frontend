import 'package:flutter_application_1/token.dart';

import 'package:http/http.dart' as http;

Future<void> signout() async {
  String? token = await getAccessToken();
  var url = Uri.parse('http://potato.seatnullnull.com/logout');
  try {
    var response = await http.post(
      url,
      headers: <String, String>{
        'access': '$token',
        'Content-Type': 'application/json',
      },
    );
    print(response.body);
  } catch (e) {
    // 요청 중에 발생한 에러 처리
    print("Error sign out: $e");
  }
}
