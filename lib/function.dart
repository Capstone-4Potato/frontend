import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_vowels.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_application_1/home/words/wordlist/word_final_consonants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';

// 음절, 단어, 문장 학습 카드 북마크 API
Future<void> updateBookmarkStatus(int cardId, bool newStatus) async {
  String? token = await getAccessToken();
  var url = Uri.parse('$main_url/cards/bookmark/$cardId');

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

// 음절, 단어, 문장 사용자 피드백 API
Future<FeedbackData?> getFeedback(
    int cardId, String base64userAudio, String base64correctAudio) async {
  Map<String, dynamic> feedbackRequest = {
    'userAudio': base64userAudio,
    'correctAudio': base64correctAudio,
  };

  String url = '$main_url/cards/$cardId';

  String? token = await getAccessToken();
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
      // Handle token expiration
      print('Access token expired. Refreshing token...');
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        token = await getAccessToken();
        response = await makePostRequest(token!);
        if (response.statusCode == 200) {
          print('Successful feedback submission after token refresh');
          var responseData = json.decode(response.body);
          return FeedbackData.fromJson(responseData);
        } else {
          print('Failed after token refresh: ${response.statusCode}');
          return null;
        }
      } else {
        print('Failed to refresh access token');
        return null;
      }
    } else if (response.statusCode == 500) {
      var responseData = json.decode(response.body);
      var message = responseData['message'];
      if (message is String) {
        var messageDetail = json.decode(message)['detail'];
        if (messageDetail ==
                "failed to extract user text (STT), please request re-recording" ||
            messageDetail == "no non-silent samples to save" ||
            messageDetail ==
                "User text is too short, please request re-recording") {
          throw Exception('ReRecordNeeded');
        }
      } else if (message is Map) {
        if (message['detail'] ==
                "failed to extract user text (STT), please request re-recording" ||
            message['detail'] == "no non-silent samples to save" ||
            message['detail' ==
                "User text is too short, please request re-recording"]) {
          throw Exception('ReRecordNeeded');
        }
      }
    }

    print('Unhandled server response: ${response.statusCode}');
    print(json.decode(response.body));
    return null;
  } catch (e) {
    print("Error during the request: $e");
    if (e.toString() == 'Exception: ReRecordNeeded') {
      // If ReRecordNeeded exception occurs, signal to the calling function
      throw Exception('ReRecordNeeded');
    }
    return null;
  }
}

// 음절, 단어, 문장 사용자 피드백 API
Future<FeedbackData?> getTodayFeedback(
    int cardId, String base64userAudio, String base64correctAudio) async {
  Map<String, dynamic> feedbackRequest = {
    'userAudio': base64userAudio,
    'correctAudio': base64correctAudio,
  };

  String url = '$main_url/cards/today/$cardId';

  String? token = await getAccessToken();
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
      // Handle token expiration
      print('Access token expired. Refreshing token...');
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        token = await getAccessToken();
        response = await makePostRequest(token!);
        if (response.statusCode == 200) {
          print('Successful feedback submission after token refresh');
          var responseData = json.decode(response.body);
          return FeedbackData.fromJson(responseData);
        } else {
          print('Failed after token refresh: ${response.statusCode}');
          return null;
        }
      } else {
        print('Failed to refresh access token');
        return null;
      }
    } else if (response.statusCode == 500) {
      var responseData = json.decode(response.body);
      var message = responseData['message'];
      if (message is String) {
        var messageDetail = json.decode(message)['detail'];
        if (messageDetail ==
                "failed to extract user text (STT), please request re-recording" ||
            messageDetail == "no non-silent samples to save" ||
            messageDetail ==
                "User text is too short, please request re-recording") {
          throw Exception('ReRecordNeeded');
        }
      } else if (message is Map) {
        if (message['detail'] ==
                "failed to extract user text (STT), please request re-recording" ||
            message['detail'] == "no non-silent samples to save" ||
            message['detail' ==
                "User text is too short, please request re-recording"]) {
          throw Exception('ReRecordNeeded');
        }
      }
    }

    print('Unhandled server response: ${response.statusCode}');
    print(json.decode(response.body));
    return null;
  } catch (e) {
    print("Error during the request: $e");
    if (e.toString() == 'Exception: ReRecordNeeded') {
      // If ReRecordNeeded exception occurs, signal to the calling function
      throw Exception('ReRecordNeeded');
    }
    return null;
  }
}

// 음절, 단어, 문장 사용자 피드백 API
Future<FeedbackData?> getCustomFeedback(
    int cardId, String base64userAudio, String base64correctAudio) async {
  Map<String, dynamic> feedbackRequest = {
    'userAudio': base64userAudio,
    'correctAudio': base64correctAudio,
  };

  String url = '$main_url/cards/custom/$cardId';

  String? token = await getAccessToken();
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
      // Handle token expiration
      print('Access token expired. Refreshing token...');
      bool isRefreshed = await refreshAccessToken();
      if (isRefreshed) {
        token = await getAccessToken();
        response = await makePostRequest(token!);
        if (response.statusCode == 200) {
          print('Successful feedback submission after token refresh');
          var responseData = json.decode(response.body);
          return FeedbackData.fromJson(responseData);
        } else {
          print('Failed after token refresh: ${response.statusCode}');
          return null;
        }
      } else {
        print('Failed to refresh access token');
        return null;
      }
    } else if (response.statusCode == 500) {
      var responseData = json.decode(response.body);
      var message = responseData['message'];
      if (message is String) {
        var messageDetail = json.decode(message)['detail'];
        if (messageDetail ==
                "failed to extract user text (STT), please request re-recording" ||
            messageDetail == "no non-silent samples to save" ||
            messageDetail ==
                "User text is too short, please request re-recording") {
          throw Exception('ReRecordNeeded');
        }
      } else if (message is Map) {
        if (message['detail'] ==
                "failed to extract user text (STT), please request re-recording" ||
            message['detail'] == "no non-silent samples to save" ||
            message['detail' ==
                "User text is too short, please request re-recording"]) {
          throw Exception('ReRecordNeeded');
        }
      }
    }

    print('Unhandled server response: ${response.statusCode}');
    print(json.decode(response.body));
    return null;
  } catch (e) {
    print("Error during the request: $e");
    if (e.toString() == 'Exception: ReRecordNeeded') {
      // If ReRecordNeeded exception occurs, signal to the calling function
      throw Exception('ReRecordNeeded');
    }
    return null;
  }
}

// 단어, 문장, 사용자문장 피드백 화면에서 잘못발음한 텍스트 표현하기 위함
Widget buildTextSpans(String text, List<int>? mistakenIndexes) {
  List<TextSpan> spans = [];
  print(text);
  if (mistakenIndexes != null)
    // ignore: curly_braces_in_flow_control_structures
    for (int i = 0; i < text.length; i++) {
      final bool isMistaken = mistakenIndexes.contains(i);
      // 잘못된 문자라면 빨간색, 그렇지 않다면 검정색
      TextStyle textStyle = isMistaken
          ? TextStyle(
              color: const Color(0xFFDE0000),
              fontSize: 32.h,
              fontWeight: FontWeight.w600,
            )
          : TextStyle(
              color: Colors.black,
              fontSize: 32.h,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            );
      spans.add(TextSpan(text: text[i], style: textStyle));
    }
  return AutoSizeText.rich(
    TextSpan(children: spans),
  );
}

// 사용자가 발음하지 못한 음절은 회색으로 표시
Widget buildTextSpansOmit(String correctText, String userText) {
  List<TextSpan> spans = [];

  for (int i = 0; i < correctText.length; i++) {
    // 사용자 발음이 올바른 문자와 일치하는지 확인
    final bool isCorrect = i < userText.length && correctText[i] == userText[i];

    // 텍스트 스타일: 올바른 발음은 black, 틀린 발음은 gray
    TextStyle textStyle = isCorrect
        ? TextStyle(
            color: Colors.black,
            fontSize: 32.h,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          )
        : TextStyle(
            color: const Color.fromARGB(255, 206, 203, 203),
            fontSize: 32.h,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          );

    // 현재 문자 추가
    spans.add(TextSpan(
      text: correctText[i],
      style: textStyle,
    ));
  }

  return AutoSizeText.rich(
    TextSpan(children: spans),
  );
}

// 추천 학습 링크 UI : 단어 / 문장 / 사용자 맞춤 문장
List<TextSpan> recommendText(List<String> ids, List<String> texts,
    List<String> categories, List<String> subcategories, BuildContext context) {
  // 색상 리스트 정의
  List<Color> colors = [Colors.green, Colors.blue, Colors.purple];
  List<TextSpan> spans = [];

  spans.add(const TextSpan(
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
      spans.add(const TextSpan(text: "\n")); // Add commas between items
    }
  }

  return spans;
}

// 단어 학습 피드백에서 추천 학습 링크 페이지 전환
void _handleTap(
    BuildContext context, String category, String subcategory, String text) {
  //페이지 이동 로직 구현

  if (category == '음절' && subcategory == '단모음') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableVowels(
              category: category,
              subcategory: subcategory,
              title: 'ㅏㅓㅗㅜ ㅡ ㅣㅐㅔ')),
    );
  } else if (category == '음절' && subcategory == '이중모음1') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableVowels(
              category: category, subcategory: subcategory, title: 'ㅑㅕㅛㅠ')),
    );
  } else if (category == '음절' && subcategory == '이중모음2') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableVowels(
              category: category,
              subcategory: subcategory,
              title: 'ㅒㅖㅘㅙㅝㅞㅚㅟㅢ')),
    );
  } else if (category == '음절' && subcategory == '자음ㄱㅋㄲ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableConsonants(
              category: category, subcategory: subcategory, title: 'ㄱㅋㄲ')),
    );
  } else if (category == '음절' && subcategory == '자음ㄷㅌㄸ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableConsonants(
              category: category, subcategory: subcategory, title: 'ㄷㅌㄸ')),
    );
  } else if (category == '음절' && subcategory == '자음ㅂㅍㅃ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableConsonants(
              category: category, subcategory: subcategory, title: 'ㅂㅍㅃ')),
    );
  } else if (category == '음절' && subcategory == '자음ㅅㅆ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableConsonants(
              category: category, subcategory: subcategory, title: 'ㅅㅆ')),
    );
  } else if (category == '음절' && subcategory == '자음ㅈㅊㅉ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableConsonants(
              category: category, subcategory: subcategory, title: 'ㅈㅊㅉ')),
    );
  } else if (category == '음절' && subcategory == '자음ㄴㄹㅁ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableConsonants(
              category: category, subcategory: subcategory, title: 'ㄴㄹㅁ')),
    );
  } else if (category == '음절' && subcategory == '자음ㅇㅎ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SyllableConsonants(
              category: category, subcategory: subcategory, title: 'ㅇㅎ')),
    );
  } else if (category == '단어' && subcategory == '받침ㄱ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordFinalConsonants(
              category: '단어', subcategory: '받침ㄱ', title: 'ㄱ')),
    );
  } else if (category == '단어' && subcategory == '받침ㄴ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordFinalConsonants(
              category: '단어', subcategory: '받침ㄴ', title: 'ㄴ')),
    );
  } else if (category == '단어' && subcategory == '받침ㄷ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordFinalConsonants(
              category: '단어', subcategory: '받침ㄷ', title: 'ㄷ')),
    );
  } else if (category == '단어' && subcategory == '받침ㄹ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordFinalConsonants(
              category: '단어', subcategory: '받침ㄹ', title: 'ㄹ')),
    );
  } else if (category == '단어' && subcategory == '받침ㅁ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordFinalConsonants(
              category: '단어', subcategory: '받침ㅁ', title: 'ㅁ')),
    );
  } else if (category == '단어' && subcategory == '받침ㅂ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordFinalConsonants(
              category: '단어', subcategory: '받침ㅂ', title: 'ㅂ')),
    );
  } else if (category == '단어' && subcategory == '받침ㅇ') {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WordFinalConsonants(
              category: '단어', subcategory: '받침ㅇ', title: 'ㅇ')),
    );
  } else {
    print('error');
  }
}
