import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### GET `home/course` : course 학습 현황 조회
/// 레벨에 맞는 카테고리의 카드 리스트를 조회한다.
Future<List<dynamic>> getLearningCourseStatusReqeust() async {
  try {
    var result = [];
    await apiRequest(
      endpoint: 'home/course',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        result = jsonDecode(response.body)['courseList'];
      },
    );
    return result;
  } catch (e) {
    debugPrint('러닝 코스 학습 현황 조회 실패 : $e');
    return [];
  }
}

/// ### GET `home/course/{level}` : cardList 조회
/// 레벨에 맞는 카테고리의 카드 리스트를 조회한다.
Future<List<dynamic>> getLearningCourseCardListReqeust(int level) async {
  try {
    var result = [];
    await apiRequest(
      endpoint: 'home/course/{level}?level=$level',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        result = jsonDecode(response.body)['cardList'];
      },
    );
    return result;
  } catch (e) {
    debugPrint('러닝 코스 cardList 조회 실패 : $e');
    return [];
  }
}

/// ### GET `cards/bookmark/{cardId}` : CardBookmark 갱신
/// 해당 카드의 북마크 on / off
Future<void> updateBookmarkStatusRequest(int cardId) async {
  try {
    await apiRequest(
      endpoint: 'cards/bookmark/$cardId',
      method: ApiMethod.get.type,
    );
  } catch (e) {
    debugPrint('card Bookmark 갱신 실패 : $e');
  }
}
