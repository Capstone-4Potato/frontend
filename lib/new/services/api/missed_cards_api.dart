import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### GET `home/missed` : 복습 cardList 조회
/// 복습 카드 리스트를 조회한다.
Future<Map<String, dynamic>> getMissedCardsListRequest() async {
  try {
    Map<String, dynamic> cardList = {};

    await apiRequest(
      endpoint: 'home/missed',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        // data 디코딩
        var data = json.decode(response.body);
        cardList = data['cardList'];
        return data;
      },
    );

    return cardList;
  } catch (e) {
    debugPrint('복습 카드 리스트 조회 실패 : $e');
    return {};
  }
}
