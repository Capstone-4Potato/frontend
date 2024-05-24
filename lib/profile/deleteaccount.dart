import 'dart:convert';

import 'package:flutter_application_1/token.dart';
import 'package:http/http.dart' as http;

Future<void> deleteaccount(String nickname) async {
  String? token = await getAccessToken();
  var url = Uri.parse('http://potato.seatnullnull.com/users');
  try {
    var response = await http.delete(
      url,
      headers: <String, String>{
        'access': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'name': nickname,
      }),
    );
    print(response.body);
  } catch (e) {
    // 요청 중에 발생한 에러 처리
    print("Error sign out: $e");
  }
}
