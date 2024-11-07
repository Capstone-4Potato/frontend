import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_home/fetch_today_course.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodayCourseScreen extends StatefulWidget {
  const TodayCourseScreen({super.key});

  @override
  State<TodayCourseScreen> createState() => _TodayCourseScreenState();
}

class _TodayCourseScreenState extends State<TodayCourseScreen> {
  List<Map<String, dynamic>> cardDetailsList = []; // 카드 정보를 담을 리스트
  List<int> cardList = []; // 학습할 카드 리스트

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
    for (int cardId in cardList) {
      await fetchTodayCourseCardList(cardId); // 각 카드 정보 가져오기
    }
    if (mounted) {
      setState(() {
        isLoading = false; // 모든 카드 정보 로딩 후 로딩 상태 업데이트
      });
    }
  }

  // 학습 카드 리스트 불러오기
  Future<void> loadCardList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCardIdList = prefs.getStringList('cardIdList');

    if (savedCardIdList != null && savedCardIdList.isNotEmpty) {
      // 카드 리스트가 이미 저장되어 있으면, 해당 리스트를 int 리스트로 변환
      setState(() {
        cardList = savedCardIdList.map(int.parse).toList();
        print(cardList);
        //isLoading = false; // 모든 카드 정보 로딩 후 로딩 상태 업데이트
        fetchAllCards();
      });
    } else {
      // 카드 리스트가 없으면 새로 요청하여 저장
      cardList = await fetchTodayCourse();
    }
  }

  @override
  void initState() {
    super.initState();
    loadCardList();
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
          : cardDetailsList.isEmpty
              ? const Center(
                  child: Text("No cards available."),
                )
              : ListView.builder(
                  itemCount: cardDetailsList.length,
                  itemBuilder: (context, index) {
                    var cardDetail = cardDetailsList[index];
                    return ListTile(
                      title: Text("Card ${cardDetail['id']}"),
                      subtitle: Text(
                          "Pronunciation: ${cardDetail['cardPronunciation']}"),
                    );
                  },
                ),
    );
  }
}
