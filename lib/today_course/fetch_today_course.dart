import 'dart:convert';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 오늘의 단어 리스트 받아오는 API
Future<List<int>> postTodayCourse() async {
  List<int> cardIdList = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // SharedPreferences에서 저장된 totalCard 값을 가져옴 (기본값 10)
  int totalCard = prefs.getInt('totalCard') ?? 10;

  // 학습할 카드 갯수 초기화 (기본값 10) 및 학습한 카드 갯수 초기화 (기본값 0)
  await prefs.setInt('courseSize', totalCard); // totalCard를 courseSize로 설정
  print("요청한 카드 갯수입니다. : $totalCard");
  await prefs.setInt('learnedCardCount', 0);
  await secureStorage.delete(key: 'lastFinishedCardId');
  print("Initilized last finished card ID");

  try {
    var url = Uri.parse('$main_url/cards/today-course');
    String? token = await getAccessToken();

    // Function to make the request
    Future<http.Response> makeRequest(String token) {
      var headers = <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      };
      var body = json.encode(<String, int>{
        'courseSize': prefs.getInt('courseSize') ?? 10,
      });
      return http.post(url, headers: headers, body: body);
    }

    var response = await makeRequest(token!);
    print("요청 직후 응답 : ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // cardIdList가 리스트인지 확인하고 처리
      if (data['cardIdList'] is List) {
        // API에서 리스트로 반환된 경우
        cardIdList = List<int>.from(data['cardIdList']);
      } else if (data['cardIdList'] is String) {
        // 문자열로 반환된 경우
        cardIdList =
            (data['cardIdList'] as String).split(', ').map(int.parse).toList();
      }

      // SharedPreferences에 cardIdList 저장
      await prefs.setStringList(
          'cardIdList', cardIdList.map((e) => e.toString()).toList());

      return cardIdList;
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
          var data = json.decode(response.body);

          // cardIdList가 리스트인지 확인하고 처리
          if (data['cardIdList'] is List) {
            // API에서 리스트로 반환된 경우
            cardIdList = List<int>.from(data['cardIdList']);
          } else if (data['cardIdList'] is String) {
            // 문자열로 반환된 경우
            cardIdList = (data['cardIdList'] as String)
                .split(', ')
                .map(int.parse)
                .toList();
          }

          // SharedPreferences에 cardIdList 저장
          await prefs.setStringList(
              'cardIdList', cardIdList.map((e) => e.toString()).toList());

          return cardIdList;
        }
      }
    }
  } catch (e) {
    print(e);
  }
  return cardIdList;
}
