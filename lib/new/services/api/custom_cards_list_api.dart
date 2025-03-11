import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### GET `home/custom` : Custom CardList 조회
/// parameter에 맞는 카테고리의 카드 리스트를 조회한다.
Future<List<dynamic>> getCustomCardsListRequest() async {
  try {
    List<dynamic> cardList = [];

    await apiRequest(
      endpoint: 'home/custom',
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
    debugPrint('Custom 카드 리스트 조회 실패 : $e');
    return [];
  }
}
