import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

///### POST `test/add` : 취약음소 추가
/// 선택한 음소들을 사용자의 취약음소로 추가한다.
Future<void> addWeakSoundRequest(List<int> addPhonemes,
    {required Function onSuccess}) async {
  try {
    await apiRequest(
      endpoint: 'test/add',
      method: ApiMethod.post.type,
      body: addPhonemes,
      onSuccess: (response) {
        onSuccess();
      },
    );
  } catch (e) {
    debugPrint('취약 음소 추가 실패 : $e');
  }
}

///### GET `test/phonemes` : 사용자의 취약 음소 제공
/// 사용자의 취약음소 4개를 제공한다.

/// ### GET `test/all` : 전체 음소 목록과 취약음소 여부 조회
/// 초성, 중성, 종성으로 분류된 전체 음소 목록과 각 음소의 취약음소 여부를 제공한다.
Future<void> getWeakSoundListRequest({
  required Function(List<dynamic>) onDataReceived,
}) async {
  try {
    await apiRequest(
      endpoint: 'test/all',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        final data = jsonDecode(response.body);
        onDataReceived(data);
        // onDataReceived(data);
      },
    );
  } catch (e) {
    debugPrint('취약 음소 정보 조회 실패 : $e');
  }
}

/// ### DELETE `test/phonemes/{phonemeId}` : 사용자의 개별 취약음소 삭제
/// 사용자의 개별 취약음소를 삭제한다.
Future<void> deleteWeakSoundRequest(int phonemeId,
    {required VoidCallback onDelete}) async {
  try {
    await apiRequest(
      endpoint: 'test/phonemes/$phonemeId',
      method: ApiMethod.delete.type,
      onSuccess: (response) {
        onDelete();
      },
    );
  } catch (e) {
    debugPrint('취약 음소 삭제 실패 : $e');
  }
}
