import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/home/syllables/syllabelearningcard.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_today_course/fetch_today_course.dart';
import 'package:flutter_application_1/new_today_course/today_course_learning_card.dart';
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

  List<int> ids = [];
  List<String> texts = [];
  List<String> correctAudios = [];

  List<String> cardTranslations = [];
  List<String> cardPronunciations = [];
  List<String> pictureUrls = [];
  List<String> explanations = [];

  List<bool> weakCards = [];
  List<bool> bookmarks = [];

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

    try {
      var response = await makeRequest(token!);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (mounted) {
          setState(() {
            ids.add(data['id']);
            texts.add(data['text']);
            correctAudios.add(data['correctAudio']);
            cardTranslations.add(data['cardTranslation']);
            cardPronunciations.add(data['cardPronunciation']);
            pictureUrls.add(data['pictureUrl']);
            explanations.add(data['explanation']);
            weakCards.add(data['weakCard']);
            bookmarks.add(data['bookmark']);

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
              'bookmark': data['bookmark'],
            });
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh the token
        print('Access token expired. Refreshing token...');

        // Refresh the access token
        bool isRefreshed = await refreshAccessToken();
        if (isRefreshed) {
          // Retry the delete request with the new token
          token = await getAccessToken();
          response = await makeRequest(token!);

          if (response.statusCode == 200) {
            var data = json.decode(response.body);
            if (mounted) {
              setState(() {
                ids.add(data['id']);
                texts.add(data['text']);
                correctAudios.add(data['correctAudio']);
                cardTranslations.add(data['cardTranslation']);
                cardPronunciations.add(data['cardPronunciation']);
                pictureUrls.add(data['pictureUrl']);
                explanations.add(data['explanation']);
                weakCards.add(data['weakCard']);
                bookmarks.add(data['bookmark']);

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
                  'bookmark': data['bookmark'],
                });
                isLoading = false;
              });
            }
            print(response.body);
          } else {
            throw Exception('Failed to load card list after refreshing token');
          }
        } else {
          throw Exception('Failed to refresh access token');
        }
      } else {
        throw Exception('Failed to load card list');
      }
    } catch (e) {
      // Handle errors that occur during the request
      print("Error loading card list: $e");
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
    setState(() {
      isLoading = true;
    });

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
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading || cardDetailsList.length < 10
          ? Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            )
          : cardDetailsList.isEmpty
              ? const Center(
                  child: Text("No cards available."),
                )
              : TodayCourseLearningCard(
                  ids: ids,
                  texts: texts,
                  correctAudios: correctAudios,
                  cardTranslations: cardTranslations,
                  cardPronunciations: cardPronunciations,
                  pictureUrls: pictureUrls,
                  explanations: explanations,
                  weakCards: weakCards,
                  bookmarks: bookmarks,
                ),
    );
  }
}
