import 'package:flutter/material.dart';

/// api 요청 응답 프린터
void responsePrinter(String url, String? response, String method) {
  debugPrint("🌰----$url----🌰"); // api 요청 주소 출력
  if (response != null) {
    debugPrint(response);
  }
  debugPrint("💨----$method----💨");
}
