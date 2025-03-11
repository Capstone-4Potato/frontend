import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ### `cards/today-course` : todayCourse 요청
/// 사용자의 레벨과 요청 개수에 맞는 카드 리스트를 제공한다.
Future<List<int>> getTodayCourseCardList() async {
  List<int> cardIdList = [];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // SharedPreferences에서 저장된 totalCard 값을 가져옴 (기본값 10)
  int totalCard = prefs.getInt('totalCard') ?? 10;

  // 학습할 카드 갯수 초기화 (기본값 10) 및 학습한 카드 갯수 초기화 (기본값 0)
  await prefs.setInt('courseSize', totalCard); // totalCard를 courseSize로 설정
  debugPrint("요청한 카드 갯수입니다. : $totalCard");
  await prefs.setInt('learnedCardCount', 0);
  await secureStorage.delete(key: 'lastFinishedCardId');
  debugPrint("Initilized last finished card ID");

  try {
    await apiRequest(
      endpoint: 'cards/today-course',
      method: ApiMethod.post.type,
      body: {
        'courseSize': prefs.getInt('courseSize') ?? 10,
      },
      onSuccess: (response) async {
        final data = jsonDecode(response.body);
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
      },
    );
    return cardIdList;
  } catch (e) {
    debugPrint('today-course 카드 ID 리스트 조회 실패 : $e');
    return [];
  }
}
