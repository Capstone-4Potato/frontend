import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

class LearningProgressScreen extends StatelessWidget {
  final double syllableProgress;
  final double wordProgress;
  final double sentenceProgress;

  const LearningProgressScreen({
    super.key,
    required this.syllableProgress,
    required this.wordProgress,
    required this.sentenceProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: const Color.fromARGB(230, 255, 255, 255),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SizedBox(height: 10),
              const Text(
                'Learning Progress Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),
              CustomProgressBar(
                value: wordProgress / 100,
                color: const Color(0xFF466CFF),
                label: 'Word',
              ),
              const SizedBox(height: 12),
              CustomProgressBar(
                value: sentenceProgress / 100,
                color: const Color(0xFF3AB9FE),
                label: 'Sentence',
              ),
              const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final String label;

  const CustomProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          // width: 210,
          width: MediaQuery.of(context).size.width * 0.58,
          height: 18,
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(2),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.58 * value,
                height: 18,
                decoration: BoxDecoration(
                  //borderRadius: BorderRadius.circular(15),
                  color: color,
                ),
              ),
              Center(
                child: Text(
                  '${(value * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<Map<String, double>> fetchProgressData() async {
  var url = Uri.parse('$main_url/learning/progress');
  String? token = await getAccessToken();

  // Function to make the request
  Future<http.Response> makeRequest(String token) {
    var headers = <String, String>{
      'access': token,
      'Content-Type': 'application/json',
    };
    return http.get(url, headers: headers);
  }

  var response = await makeRequest(token!);

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return {
      'syllableProgress': data['syllableProgress'],
      'wordProgress': data['wordProgress'],
      'sentenceProgress': data['sentenceProgress'],
    };
  } else if (response.statusCode == 401) {
    // Token expired, attempt to refresh the token
    print('Access token expired. Refreshing token...');

    // Refresh the access token
    bool isRefreshed = await refreshAccessToken();
    if (isRefreshed) {
      // Retry the request with the new token
      token = await getAccessToken();
      response = await makeRequest(token!);

      if (response.statusCode == 200) {
        print("토큰 재발급 후 학습 진척도 정보 가져오기 성공");
        var data = json.decode(response.body);
        return {
          'syllableProgress': data['syllableProgress'],
          'wordProgress': data['wordProgress'],
          'sentenceProgress': data['sentenceProgress'],
        };
      } else {
        throw Exception('Failed to load progress data after refreshing token');
      }
    } else {
      throw Exception('Failed to refresh access token');
    }
  } else {
    throw Exception('Failed to load progress data');
  }
}
