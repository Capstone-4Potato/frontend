import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/api/today_course_api.dart';
import 'package:flutter_application_1/today_course/today_course_learning_card.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
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
  int courseSize = 10; // couse Size

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
        debugPrint('Access token expired. Refreshing token...');

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
            debugPrint(response.body);
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
      debugPrint("Error loading card list: $e");
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
    debugPrint("마지막 카드 아이디 입니다 : $lastFinishedCardId");

    setState(() {
      // 마지막으로 학습한 카드의 인덱스 찾기
      int lastFinishedIndex = cardList.indexOf(lastFinishedCardId);

      if (lastFinishedIndex != -1) {
        // 인덱스를 찾은 경우, 그 이후의 카드들만 유지
        cardList = cardList.sublist(lastFinishedIndex);
      } else {
        // 마지막 카드 ID를 리스트에서 찾을 수 없는 경우
        debugPrint("마지막 카드 ID를 리스트에서 찾을 수 없습니다.");
        getTodayCourseCardList();
      }

      debugPrint("필터링 이후 카드 리스트입니다 : $cardList");
    });

    if (cardList.isEmpty) {
      // 카드가 모두 끝난 경우 새 카드 요청
      debugPrint("All cards finished. Fetching new cards...");
      await getTodayCourseCardList();
      await Future.delayed(const Duration(seconds: 2)); // 2초 대기
    } else {
      //fetchAllCards();
    }
  }

  // 마지막 학습 카드 ID 저장
  Future<void> saveLastFinishedCard(int cardId) async {
    await secureStorage.write(
        key: 'lastFinishedCardId', value: cardId.toString());
    debugPrint("Saved last finished card ID: $cardId");
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
      cardList = await getTodayCourseCardList(); // 이 작업이 완료될 때까지 기다림
      if (cardList.isNotEmpty) {
        // cardList가 제대로 업데이트되었는지 확인
        await fetchAllCards();
      } else {
        debugPrint("No cards available from server.");
      }
    } catch (e) {
      debugPrint("Error fetching new cards: $e");
    } finally {
      setState(() {
        isLoading = false; // 로딩 상태 종료
      });
    }
  }

  // 학습 카드 리스트 불러오기
  Future<void> loadCardList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCardIdList = prefs.getStringList('cardIdList');
    debugPrint("저장됐던 카드 리스트 입니다 : $savedCardIdList");
    setState(() {
      isLoading = true;
    });

    if (savedCardIdList != null && savedCardIdList.isNotEmpty) {
      setState(() {
        cardList = savedCardIdList.map(int.parse).toList();
      });

      // 마지막 학습한 카드 이후 카드 필터링
      await filterCardsAfterLastFinished();
      debugPrint("새로 저장한 카드 리스트 입니다 : $savedCardIdList");

      // 카드 정보를 한 번만 요청
      if (cardList.isNotEmpty) {
        await fetchAllCards(); // 이미 필터링된 카드 리스트로만 정보 요청
      }
    } else {
      // 카드 리스트가 비어있으면 서버에서 새로 요청
      debugPrint("Fetching new cards...");
      await fetchTodayCourseCards();
    }

    setState(() {
      isLoading = false;
    });
  }

  // CourseSize 불러오기
  Future<void> loadCourseSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseSize = prefs.getInt('totalCard') ?? 10;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCourseSize();
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
              courseSize: courseSize,
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
