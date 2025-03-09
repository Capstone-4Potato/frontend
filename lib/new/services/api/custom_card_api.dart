import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### POST `cards/custom` : customCard 생성
/// text 해당하는 custom card를 생성한다
Future<void> createCustomCardRequest(
  String text, {
  required Function(Map<String, dynamic>) onDataReceived,
}) async {
  try {
    await apiRequest(
      endpoint: 'cards/custom',
      method: ApiMethod.post.type,
      body: {'text': text},
      onSuccess: (response) {
        final data = jsonDecode(response.body);
        onDataReceived(data);
      },
    );
  } catch (e) {
    debugPrint('customCard 생성 실패 : $e');
  }
}

/// ### DELETE `cards/custom/{cardId}` : customCard 삭제
/// 원하는 custom card를 삭제한다
Future<void> deleteCustomCardRequest(
  int cardId, {
  required Function onDataReceived,
}) async {
  try {
    await apiRequest(
      endpoint: 'cards/custom/$cardId',
      method: ApiMethod.delete.type,
      body: {'cardId': cardId},
      onSuccess: (response) {
        onDataReceived();
      },
    );
  } catch (e) {
    debugPrint('customCard 삭제 실패 : $e');
  }
}
