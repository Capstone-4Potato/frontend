import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/syllablelist/syllable_consonants_1.dart';
import 'package:flutter_application_1/syllablelist/syllable_consonants_2.dart';
import 'package:flutter_application_1/syllablelist/syllable_consonants_3.dart';
import 'package:flutter_application_1/syllablelist/syllable_consonants_4.dart';
import 'package:flutter_application_1/syllablelist/syllable_consonants_5.dart';
import 'package:flutter_application_1/syllablelist/syllable_consonants_6.dart';
import 'package:flutter_application_1/syllablelist/syllable_consonants_7.dart';
import 'package:flutter_application_1/syllablelist/syllable_vowels_1.dart';
import 'package:flutter_application_1/syllablelist/syllable_vowels_2.dart';
import 'package:flutter_application_1/syllablelist/syllable_vowels_3.dart';
import 'package:flutter_application_1/token.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_1.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_2.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_3.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_4.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_5.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_6.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_7.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
//import 'dart:io';

Future<void> updateBookmarkStatus(int cardId, bool newStatus) async {
  String? token = await getAccessToken();
  var url = Uri.parse('http://potato.seatnullnull.com/cards/bookmark/$cardId');
  try {
    var response = await http.get(
      url,
      headers: <String, String>{
        'access': '$token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // OK : 북마크 UPDATE(있으면 삭제 없으면 추가)
      print(response.body);
    }
    if (response.statusCode == 400) {
      // ERROR : 존재하지 않는 카드
      print(json.decode(response.body));
    }
  } catch (e) {
    // 요청 중에 발생한 에러 처리
    print("Error updating bookmark status: $e");
  }
}

Future<FeedbackData?> getFeedback(
    int cardId, String base64userAudio, String base64correctAudio) async {
  Map<String, dynamic> feedbackRequest = {
    'userAudio': base64userAudio,
    'correctAudio': base64correctAudio,
  };

  String url = 'http://potato.seatnullnull.com/cards/$cardId';

  String? token = await getAccessToken();

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {'access': '$token', "Content-Type": "application/json"},
      body: jsonEncode(feedbackRequest),
    );
    //print('post 했음');
    if (response.statusCode == 200) {
      print('성공');
      var responseData = json.decode(response.body);
      print(responseData['waveform']['userAudioDuration']);
      print(responseData['waveform']['correctAudioDuration']);
      // saveToFile(responseData);

      return FeedbackData.fromJson(responseData);
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      print(response.statusCode);
      print('실패1');
      // ERROR 처리: JSON 형식 오류 또는 존재하지 않는 사용자/카드
      print(json.decode(response.body));
      return null;
    } else {
      // 기타 모든 HTTP 상태 코드 처리
      print('Unhandled server response: ${response.statusCode}');
      print(json.decode(response.body));
      print('실패2');
      return null;
    }
  } catch (e) {
    print('실패3');

    // 네트워크 요청 중에 발생한 예외 처리
    print("Error during the request: $e");
    return null;
  }
}

List<TextSpan> buildTextSpans(String text, List<int> mistakenIndexes) {
  List<TextSpan> spans = [];
  for (int i = 0; i < text.length; i++) {
    final bool isMistaken = mistakenIndexes.contains(i);
    TextStyle textStyle = isMistaken
        ? TextStyle(
            color: Color(0xFFFF0000), fontSize: 20, fontWeight: FontWeight.bold)
        : TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);
    spans.add(TextSpan(text: text[i], style: textStyle));
  }
  return spans;
}

List<TextSpan> recommendText(List<String> ids, List<String> texts,
    List<String> categories, List<String> subcategories, BuildContext context) {
  // 색상 리스트 정의
  List<Color> colors = [Colors.green, Colors.blue, Colors.purple];
  List<TextSpan> spans = [];
  if (texts.contains('perfect')) {
    spans.add(TextSpan(
      text: '👍🏼 Excellent 👍🏼',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black, // 기본 텍스트 색상
      ),
    ));
    return spans;
  } else if (texts.contains('not word') || texts.contains('try again')) {
    spans.add(TextSpan(
      text: '🥺 Try Again 🥺',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black, // 기본 텍스트 색상
      ),
    ));
    return spans;
  } else if (texts.contains('drop the extra sound')) {
    spans.add(TextSpan(
      text: 'Drop the extra sound',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black, // 기본 텍스트 색상
      ),
    ));
    return spans;
  } else {
    spans.add(TextSpan(
        text: 'Practice  ',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        )));
    for (var i = 0; i < texts.length; i++) {
      spans.add(
        TextSpan(
          text: texts[i],
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors[i % colors.length], // 색상 선택
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _handleTap(context, categories[i], subcategories[i], texts[i]);
            },
        ),
      );
      if (i < texts.length - 1) {
        spans.add(TextSpan(text: "\n")); // Add commas between items
      }
    }
    // spans.add(TextSpan(
    //     text: ' 연습해보세요!',
    //     style: TextStyle(
    //       fontSize: 18,
    //       fontWeight: FontWeight.w500,
    //       color: Colors.black,
    //     )));
    return spans;
  }
}

void _handleTap(
    BuildContext context, String category, String subcategory, String text) {
  //페이지 이동 로직 구현
  if (category == '음절' && subcategory == '단모음') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableVowels1()),
    );
  } else if (category == '음절' && subcategory == '이중모음1') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableVowels2()),
    );
  } else if (category == '음절' && subcategory == '이중모음2') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableVowels3()),
    );
  } else if (category == '음절' && subcategory == '자음ㄱㅋㄲ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableConsonants1()),
    );
  } else if (category == '음절' && subcategory == '자음ㄷㅌㄸ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableConsonants2()),
    );
  } else if (category == '음절' && subcategory == '자음ㅂㅍㅃ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableConsonants3()),
    );
  } else if (category == '음절' && subcategory == '자음ㅅㅆ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableConsonants4()),
    );
  } else if (category == '음절' && subcategory == '자음ㅈㅊㅉ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableConsonants5()),
    );
  } else if (category == '음절' && subcategory == '자음ㄴㄹㅁ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableConsonants6()),
    );
  } else if (category == '음절' && subcategory == '자음ㅇㅎ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SyllableConsonants7()),
    );
  } else if (category == '단어' && subcategory == '받침ㄱ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordFinalConsonants1()),
    );
  } else if (category == '단어' && subcategory == '받침ㄴ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordFinalConsonants2()),
    );
  } else if (category == '단어' && subcategory == '받침ㄷ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordFinalConsonants3()),
    );
  } else if (category == '단어' && subcategory == '받침ㄹ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordFinalConsonants4()),
    );
  } else if (category == '단어' && subcategory == '받침ㅁ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordFinalConsonants5()),
    );
  } else if (category == '단어' && subcategory == '받침ㅂ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordFinalConsonants6()),
    );
  } else if (category == '단어' && subcategory == '받침ㅇ') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WordFinalConsonants7()),
    );
  } else {
    print('error');
  }
}

// void saveToFile(String data) {
//   File file = File('responseData.txt');
//   file.writeAsString(data).then((_) {
//     print('Data saved to file.');
//   }).catchError((e) {
//     print('Error saving file: $e');
//   });
// }
