import 'package:flutter_application_1/token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateCustomBookmark(int cardId, bool newStatus) async {
  String? token = await getAccessToken();
  var url =
      Uri.parse('http://potato.seatnullnull.com/cards/custom/bookmark/$cardId');
  try {
    var response = await http.get(
      url,
      headers: <String, String>{
        'access': '$token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // OK : 북마크 UPDATE(있으면 삭제 없으면 추가)
      print(response.body);
    }
    if (response.statusCode == 400) {
      // ERROR : 존재하지 않는 카드
      print(json.decode(response.body));
    }
  } catch (e) {
    // 요청 중에 발생한 에러 처리
    print("Error updating bookmark status: $e");
  }
}
