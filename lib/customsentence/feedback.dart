import 'package:flutter_application_1/token.dart';
import 'dart:convert';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:http/http.dart' as http;

Future<FeedbackData?> customFeedback(
    int cardId, String base64userAudio, String base64correctAudio) async {
  Map<String, dynamic> feedbackRequest = {
    'userAudio': base64userAudio,
    'correctAudio': base64correctAudio,
  };

  String url = 'http://potato.seatnullnull.com/cards/custom/$cardId';

  String? token = await getAccessToken();

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {'access': '$token', "Content-Type": "application/json"},
      body: jsonEncode(feedbackRequest),
    );
    //print('post 했음');
    if (response.statusCode == 200) {
      print('성공');
      var responseData = json.decode(response.body);
      print(responseData);
      return FeedbackData.fromJson(responseData);
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      print(response.statusCode);
      print('실패1');
      // ERROR 처리: JSON 형식 오류 또는 존재하지 않는 사용자/카드
      print(json.decode(response.body));
      return null;
    } else {
      // 기타 모든 HTTP 상태 코드 처리
      print('Unhandled server response: ${response.statusCode}');
      print(json.decode(response.body));
      print('실패2');
      return null;
    }
  } catch (e) {
    print('실패3');

    // 네트워크 요청 중에 발생한 예외 처리
    print("Error during the request: $e");
    return null;
  }
}
