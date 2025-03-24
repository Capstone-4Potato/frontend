import 'dart:typed_data';
import 'package:flutter_application_1/main.dart';
import 'package:http/http.dart' as http;

// 음절 학습 카드 이미지 API
Future<Uint8List> fetchImage(String pictureUrl) async {
  final String url = '$mainUrl$pictureUrl';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image');
  }
}
