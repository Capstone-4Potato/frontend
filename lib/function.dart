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
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_1.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_2.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_3.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_4.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_5.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_6.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_7.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';

Future<void> updateBookmarkStatus(int cardId, bool newStatus) async {
  String? token = await getAccessToken();
  var url = Uri.parse('http://potato.seatnullnull.com/cards/bookmark/$cardId');

  // Function to make the GET request
  Future<http.Response> makeGetRequest(String token) {
    return http.get(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  try {
    var response = await makeGetRequest(token!);

    if (response.statusCode == 200) {
      print(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the bookmark status update request with the new token
        token = await getAccessToken();
        response = await makeGetRequest(token!);

        if (response.statusCode == 200) {
          print('Bookmark status updated successfully after token refresh');
          print(response.body);
        } else {
          print(
              'Failed to update bookmark status after token refresh: ${response.statusCode}');
        }
      } else {
        print('Failed to refresh access token');
      }
    } else {
      // Handle all other HTTP status codes
      print('Unhandled server response: ${response.statusCode}');
      print(json.decode(response.body));
    }
  } catch (e) {
    // Handle exceptions that occur during the network request
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

  // Function to make the POST request
  Future<http.Response> makePostRequest(String token) {
    return http.post(
      Uri.parse(url),
      headers: {'access': token, "Content-Type": "application/json"},
      body: jsonEncode(feedbackRequest),
    );
  }

  try {
    var response = await makePostRequest(token!);

    if (response.statusCode == 200) {
      print('Successful feedback submission');
      var responseData = json.decode(response.body);
      return FeedbackData.fromJson(responseData);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh the token
      print('Access token expired. Refreshing token...');

      // Refresh the access token
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        // Retry the feedback request with the new token
        token = await getAccessToken();
        response = await makePostRequest(token!);

        if (response.statusCode == 200) {
          print('Successful feedback submission after token refresh');
          var responseData = json.decode(response.body);
          return FeedbackData.fromJson(responseData);
        } else {
          print(
              'Failed to submit feedback after token refresh: ${response.statusCode}');
          return null;
        }
      } else {
        print('Failed to refresh access token');
        return null;
      }
    } else {
      // Handle all other HTTP status codes
      print('Unhandled server response: ${response.statusCode}');
      print(json.decode(response.body));
      return null;
    }
  } catch (e) {
    // Handle exceptions that occur during the network request
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
        text: 'Practice ',
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
