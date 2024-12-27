import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/home/syllables/syllabelearningcard.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_today_course/fetch_today_course.dart';
import 'package:flutter_application_1/new_today_course/today_course_learning_card.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  int lastFinishedCardId = 0; // 마지막 학습 완료 카드 ID

  /// 카드 번호별 정보 요청해서 저장
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
            pictureUrls.add(data['pictureUrl'] ?? '');
            explanations.add(data['explanation'] ?? '');
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

  /// 카드 리스트에 있는 카드 id별로 카드 정보 저장
  Future<void> fetchAllCards() async {
    for (int cardId in cardList) {
      await fetchTodayCourseCardList(cardId); // 각 카드 정보 가져오기
    }
  }

  Future<void> filterCardsAfterLastFinished() async {
    lastFinishedCardId = await loadLastFinishedCard();
    print(lastFinishedCardId);
    setState(() {
      // 마지막 학습한 카드 이후의 카드만 남기기
      cardList =
          cardList.where((cardId) => cardId > lastFinishedCardId).toList();
      print("hihi : $cardList");
    });

    if (cardList.isEmpty) {
      // 카드가 모두 끝난 경우 새 카드 요청
      print("All cards finished. Fetching new cards...");
      await postTodayCourse();
      await Future.delayed(const Duration(seconds: 2)); // 1초 대기
    } else {
      //fetchAllCards();
    }
  }

  // 마지막 학습 카드 ID 저장
  Future<void> saveLastFinishedCard(int cardId) async {
    await secureStorage.write(
        key: 'lastFinishedCardId', value: cardId.toString());
    print("Saved last finished card ID: $cardId");
  }

  // 마지막 학습 카드 ID 불러오기
  Future<int> loadLastFinishedCard() async {
    String? savedCardId = await secureStorage.read(key: 'lastFinishedCardId');
    return savedCardId != null ? int.parse(savedCardId) : 0;
  }

  Future<void> fetchTodayCourseCards() async {
    setState(() {
      isLoading = true;
    });
    try {
      // 새로운 카드 리스트 요청

      if (cardList.isNotEmpty) {
        await fetchAllCards();
        // lastFinishedCard 초기화
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove(
            'lastFinishedCard'); // SharedPreferences에서 lastFinishedCard 값 제거
      } else {
        print("No cards available from server.");
      }
    } catch (e) {
      print("Error fetching new cards: $e");
    } finally {}
  }

  // 학습 카드 리스트 불러오기
  Future<void> loadCardList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCardIdList = prefs.getStringList('cardIdList');
    setState(() {
      isLoading = true;
    });

    if (savedCardIdList != null && savedCardIdList.isNotEmpty) {
      setState(() {
        cardList = savedCardIdList.map(int.parse).toList();
      });

      // 마지막 학습한 카드 이후 카드 필터링
      await filterCardsAfterLastFinished();

      // 카드 정보를 한 번만 요청
      if (cardList.isNotEmpty) {
        await fetchAllCards(); // 이미 필터링된 카드 리스트로만 정보 요청
      }
    } else {
      // 카드 리스트가 비어있으면 서버에서 새로 요청
      print("Fetching new cards...");
      await fetchTodayCourseCards();
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
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
