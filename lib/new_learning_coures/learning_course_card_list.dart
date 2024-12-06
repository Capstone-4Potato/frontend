import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

/// 레벨 별로 카드 리스트 불러옴
class LearningCourseCardList extends StatefulWidget {
  LearningCourseCardList({
    super.key,
    required this.level,
  });

  int level;

  @override
  State<LearningCourseCardList> createState() => _LearningCourseCardListState();
}

class _LearningCourseCardListState extends State<LearningCourseCardList> {
  List<int> idList = [];
  List<String> textList = [];
  List<String> engTranslationList = [];
  List<String> engPronunciationList = [];
  List<int> cardScoreList = [];
  List<String> pictureUrlList = [];
  List<String> explanationList = [];
  List<bool> weakCardList = [];
  List<bool> bookmarkList = [];

  bool isLoading = true;

  Future<void> fetchCardList() async {
    String? token = await getAccessToken();
    var url = Uri.parse('$main_url/home/course/{level}?level=${widget.level}');

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

      List<dynamic> cardList = data['cardList'];
      if (mounted) {
        setState(() {
          // 리스트 초기화
          idList.clear();
          textList.clear();
          engTranslationList.clear();
          engPronunciationList.clear();
          cardScoreList.clear();
          pictureUrlList.clear();
          explanationList.clear();
          weakCardList.clear();
          bookmarkList.clear();

          // 변수 리스트에 데이터 저장
          for (var card in cardList) {
            idList.add(card['id']);
            textList.add(card['text']);
            engTranslationList.add(card['engTranslation']);
            engPronunciationList.add(card['engPronunciation']);
            cardScoreList.add(card['cardScore']);
            pictureUrlList.add(card['pictureUrl']);
            explanationList.add(card['explanation']);
            weakCardList.add(card['weakCard']);
            bookmarkList.add(card['bookmark']);
          }
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load card list');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Course')),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 6 / 4.3,
              ),
              itemCount: idList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // 추후 추가
                  },
                  child: Opacity(
                    // 카드의 학습 완료 정도에 따라 투명도 조절
                    opacity: cardScoreList[index] >= 1.0 ? 0.5 : 1.0,
                    child: Card(
                      elevation: 0.0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // 카드의 내용 표시
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  textList[index],
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: weakCardList[index]
                                          ? const Color.fromARGB(
                                              236, 255, 85, 85)
                                          : Colors.black),
                                ),
                              ),
                              Text(engPronunciationList[index],
                                  style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
