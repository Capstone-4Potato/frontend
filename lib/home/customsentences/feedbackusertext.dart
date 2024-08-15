import 'package:flutter/material.dart';

// 공백 포함 최대 25자 -> 글씨 크기 조절

List<TextSpan> customUserText(String text, List<int> mistakenIndexes) {
  List<TextSpan> spans = [];
  for (int i = 0; i < text.length; i++) {
    final bool isMistaken = mistakenIndexes.contains(i);
    TextStyle textStyle = isMistaken
        ? TextStyle(
            color: Color(0xFFFF0000), fontSize: 14, fontWeight: FontWeight.bold)
        : TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
    spans.add(TextSpan(text: text[i], style: textStyle));
  }
  return spans;
}
