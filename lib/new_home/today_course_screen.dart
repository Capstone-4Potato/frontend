import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_home/fetch_today_course.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

class TodayCourseScreen extends StatefulWidget {
  const TodayCourseScreen({super.key});

  @override
  State<TodayCourseScreen> createState() => _TodayCourseScreenState();
}

class _TodayCourseScreenState extends State<TodayCourseScreen> {
  List<Map<String, dynamic>> cardDetailsList = []; // 카드 정보를 담을 리스트

  List<int> idList = [];
  List<String> textList = [];
  List<String> correctAudio = [];
  List<String> cardTranslationList = [];
  List<String> cardPronunciationList = [];
  List<String> pictureUrlList = [];
  List<String> explanationList = [];
  List<bool> weakCardList = [];
  List<bool> bookmarkList = [];

  bool isLoading = true;

  Future<void> fetchTodayCourseCardList(int cardId) async {
    String? token = await getAccessToken();
    var url = Uri.parse('$main_url/cards/$cardId');

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
      if (mounted) {
        setState(() {
          // 각 카드의 데이터를 리스트에 추가
          cardDetailsList.add({
            'id': data['id'],
            'text': data['text'],
            'correctAudio': data['correctAudio'],
            'cardTranslation': data['cardTranslation'],
            'cardPronunciation': data['cardPronunciation'],
            'pictureUrl': data['pictureUrl'],
            'explanation': data['explanation'],
            'weakCard': data['weakCard'],
            'bookmark': data['bookmark']
          });
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load card list');
    }
  }

  Future<void> fetchAllCards() async {
    List<int> cardIdList = await fetchTodayCourse(); // card id 리스트들

    for (int cardId in cardIdList) {
      await fetchTodayCourseCardList(cardId); // 각 카드 정보 가져오기
      print(cardDetailsList[cardId]);
    }
    setState(() {
      isLoading = false; // 모든 카드 정보 로딩 후 로딩 상태 업데이트
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Course!"),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            )
          : Container(),
    );
  }
}
