import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';

/// ### POST `test/{cardId}` : 사용자 음성파일 업로드 및 테스트
/// 사용자 음성 파일을 업로드하고 AI와의 테스트 결과를 반환한다.
Future<int> getTestResultByCard(int cardId, File audioFile) async {
  try {
    int resultCode = 500; // Default error code

    await apiRequest(
      endpoint: 'test/$cardId',
      method: ApiMethod.post.type,
      isMultipart: true,
      multipartFiles: {
        'userAudio': audioFile,
      },
      onSuccess: (response) {
        resultCode = response.statusCode;
      },
      onError: (statusCode, errorBody) {
        resultCode = statusCode;
      },
    );

    return resultCode;
  } catch (e) {
    debugPrint('사용자 음성 파일 업로드 실패 : $e');
    return 500;
  }
}

/// ### POST `test/new` : 새로운 취약음소 테스트 시작
/// 이전 테스트 데이터를 삭제하고 새로운 테스트를 시작한다.
Future<List<dynamic>?> getTestNewDataRequest() async {
  try {
    // apiRequest 함수 자체의 반환값을 사용
    final result = await apiRequest(
      endpoint: 'test/new',
      method: ApiMethod.post.type,
    );

    // result가 List 타입인지 확인
    if (result is List) {
      return result;
    } else {
      debugPrint('예상치 못한 응답 형식: ${result?.runtimeType}');
      return [];
    }
  } catch (e) {
    debugPrint('새로운 취약음 테스트 목록 반환 실패 : $e');
    return [];
  }
}

/// ### POST `test/finalize` : 취약음소 분석 완료
/// 사용자의 취약음소 분석을 완료하고, 결과를 저장한다.
Future<int> sendTestFinalizeRequest() async {
  try {
    int resultCode = 500;

    await apiRequest(
      endpoint: 'test/finalize',
      method: ApiMethod.post.type,
      onSuccess: (response) {
        resultCode = 200;
      },
      onError: (p0, p1) {
        resultCode = 404;
      },
    );

    return resultCode;
  } catch (e) {
    debugPrint('취약음소 분석 완료 전송 실패 : $e');
    return 500;
  }
}

/// ### GET `test/continue` : 취약음소 테스트 이어하기
/// 마지막으로 진행했던 테스트 이후부터 목록을 반환한다.
Future<List<dynamic>?> getTestContinueDataRequest() async {
  try {
    final result = await apiRequest(
      endpoint: 'test/continue',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        final data = jsonDecode(response.body);
        return data;
      },
    );
    return result;
  } catch (e) {
    debugPrint('취약음 테스트 이어하기 목록 반환 실패 : $e');
    return [];
  }
}

/// ### GET `test/check` : 취약음소 테스트 존재 여부 확인
/// 이전에 진행중이던 테스트가 있는지 확인한다.
Future<bool> getUnfinishedTestRequest() async {
  try {
    bool hasUnfinishedTest = false;

    await apiRequest(
      endpoint: 'test/check',
      method: ApiMethod.get.type,
      onSuccess: (response) {
        // data 디코딩
        var data = json.decode(response.body);
        hasUnfinishedTest = data['hasUnfinishedTest'];
      },
    );

    return hasUnfinishedTest; // 진행 중인 테스트가 있으면 `true` 반환
  } catch (e) {
    debugPrint('취약음소 테스트 존재 여부 확인 실패 : $e');
    return false;
  }
}
