import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_application_1/new/utils/response_printer.dart';
import 'package:http/http.dart' as http;

Future<dynamic> apiRequest({
  required String endpoint,
  required String method,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  bool requiresAuth = true,
  bool autoRefresh = true,
  Function(http.Response)? onSuccess, // 요청 성공 후 호출
  Function(int, String)? onError, // 요청 실패 시 호출
  Function(dynamic)? onComplete, // 성공 여부와 관계없이 항상 실행
}) async {
  String url = '$main_url/$endpoint';
  var urlParse = Uri.parse(url);

  // default headers 빌드
  Map<String, String> requestHeaders = {
    'Content-Type': 'application/json',
  };

  // Add authentication token if required
  if (requiresAuth) {
    String? token = await getAccessToken();
    if (token != null) {
      requestHeaders['access'] = token;
    } else {
      throw Exception('AccessToken is null : 토큰이 필요합니다.');
    }
  }

  // 헤더 추가
  if (headers != null) {
    requestHeaders.addAll(headers);
  }

  // HTTP 요청 메소드에 따른 함수
  Future<http.Response> makeRequest() async {
    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(urlParse, headers: requestHeaders);
      case 'POST':
        return http.post(
          urlParse,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return http.put(
          urlParse,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return http.delete(
          urlParse,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PATCH':
        return http.patch(
          urlParse,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      default:
        throw Exception('지원되지 않는 HTTP 형식: $method');
    }
  }

  try {
    // request 생성
    var response = await makeRequest();

    // 상태에 따라 refreshToken 재발급
    if (response.statusCode == 401 && requiresAuth && autoRefresh) {
      debugPrint('Access token 만료. Token 리프레시 중...');

      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // token 업데이트
        String? newToken = await getAccessToken();
        requestHeaders['access'] = newToken!;

        // 다시 요청 보냄
        response = await makeRequest();
      } else {
        if (onError != null) {
          onError(401, 'access token refresh 실패');
        }
        throw Exception('access token refresh 실패');
      }
    }

    // 응답 log 찍기
    responsePrinter(url, response.body, method);

    // statusCode가 200번대 일 경우
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 성공했을 경우 callBack 함수 호출
      if (onSuccess != null) {
        onSuccess(response);
      }

      // response 파싱
      dynamic result;
      try {
        result = jsonDecode(response.body);
      } catch (e) {
        result = response.body;
      }

      // 성공 실패 여부와 상관없이 실행
      if (onComplete != null) {
        onComplete(result);
      }

      return result;
    } else {
      // 에러 났을 때 함수 실행
      if (onError != null) {
        onError(response.statusCode, response.body);
      }
      throw Exception('api 요청 실패 : ${response.statusCode}');
    }
  } catch (e) {
    debugPrint("Error in $method request to $endpoint: $e");
    rethrow;
  }
}
