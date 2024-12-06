import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

// 맞춤 문장 피드백 API
Future<FeedbackData?> customFeedback(
    int cardId, String base64userAudio, String base64correctAudio) async {
  Map<String, dynamic> feedbackRequest = {
    'userAudio': base64userAudio,
    'correctAudio': base64correctAudio,
  };

  String url = '$main_url/cards/custom/$cardId';

  String? token = await getAccessToken();
  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {'access': '$token', "Content-Type": "application/json"},
      body: jsonEncode(feedbackRequest),
    );

    if (response.statusCode == 200) {
      print('성공');
      var responseData = json.decode(response.body);
      print(responseData);
      return FeedbackData.fromJson(responseData);
    } else if (response.statusCode == 401) {
      // Token expired, attempt to refresh and retry the request
      print('Access token expired. Refreshing token...');

      // Refresh the token
      bool isRefreshed = await refreshAccessToken();

      if (isRefreshed) {
        // Retry request with new token
        print('Token refreshed successfully. Retrying request...');
        String? newToken = await getAccessToken();
        response = await http.post(
          Uri.parse(url),
          headers: {'access': '$newToken', "Content-Type": "application/json"},
          body: jsonEncode(feedbackRequest),
        );

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          print(responseData);
          return FeedbackData.fromJson(responseData);
        } else if (response.statusCode == 500) {
          // 다이알로그 띄우기
          // {statusCode: 500, exceptionName: AiGenerationFailException, message: {"detail":"No non-silent samples to save"}, exceptionLevel: ERROR}
        } else {
          // Handle other response codes after retry if needed
          print(
              'Unhandled server response after retry: ${response.statusCode}');
          print(json.decode(response.body));
          return null;
        }
      } else {
        print('Failed to refresh token. Please log in again.');
        return null;
      }
    } else {
      // Handle other status codes
      print('Unhandled server response: ${response.statusCode}');
      print(json.decode(response.body));
      return null;
    }
  } catch (e) {
    // Handle network request exceptions
    print("Error during the request: $e");
    return null;
  }
  return null;
}
