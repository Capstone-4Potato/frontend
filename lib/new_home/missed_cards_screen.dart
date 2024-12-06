import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class MissedCardsScreen extends StatefulWidget {
  const MissedCardsScreen({
    super.key,
  });

  @override
  State<MissedCardsScreen> createState() => _MissedCardsScreenState();
}

class _MissedCardsScreenState extends State<MissedCardsScreen> {
  List<int> idList = [];
  List<String> textList = [];
  List<String> cardPronunciationList = [];
  List<int> cardScoreList = [];
  List<bool> weakCardList = [];
  List<bool> bookmarkList = [];

  bool isLoading = true;

  Future<void> fetchSavedCardList() async {
    String? token = await getAccessToken();
    var url = Uri.parse('$main_url/home/missed');

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

      Map<String, dynamic> cardList = data['cardList'];
      if (mounted) {
        setState(() {
          // 리스트 초기화
          idList.clear();
          textList.clear();
          cardScoreList.clear();
          weakCardList.clear();
          bookmarkList.clear();

          // 중첩 루프를 사용해 모든 카드 데이터를 리스트에 추가
          for (var entry in cardList.values) {
            for (var card in entry) {
              idList.add(card['id']);
              textList.add(card['text']);
              cardPronunciationList.add(card['cardPronunciation']);
              cardScoreList.add(card['cardScore']);
              weakCardList.add(card['weakCard']);
              bookmarkList.add(card['bookmarked']);
            }
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
    fetchSavedCardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0, // 스크롤 엘레베이션 0
        backgroundColor: const Color(0xFFF2EBE3),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: bam,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: Text(
          'Missed Cards',
          style: TextStyle(
            color: bam,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            )
          : idList.isEmpty
              ? const Center(
                  child: Text(
                    "There is no Missed Cards!",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 15.w,
                    mainAxisSpacing: 15.w,
                    childAspectRatio: 3.3 / 1,
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
                          child: (idList[index] >= 1684) // 문장이 아닌 단어이면
                              ? Stack(
                                  children: [
                                    // 카드의 내용 표시
                                    SizedBox(
                                      width: 360.w,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text(
                                              textList[index],
                                              style: TextStyle(
                                                  fontSize: 20.h,
                                                  fontWeight: FontWeight.bold,
                                                  color: weakCardList[
                                                          index] // 취약음이면
                                                      ? const Color.fromARGB(
                                                          236, 255, 85, 85)
                                                      : Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 0.2.h,
                                      right: 0.2.w,
                                      child: IconButton(
                                        icon: Icon(
                                          bookmarkList[index]
                                              ? Icons.bookmark
                                              : Icons.bookmark_border_sharp,
                                          color: bookmarkList[index]
                                              ? const Color(0xFFF26647)
                                              : Colors.grey[400],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            bookmarkList[index] =
                                                !bookmarkList[index];
                                          });
                                          updateBookmarkStatus(
                                              idList[index],
                                              bookmarkList[
                                                  index]); // 북마크 상태 서버에 업데이트
                                        },
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: LinearProgressIndicator(
                                          value: cardScoreList[index]
                                              .toDouble(), // 현재 값 / 최대 값
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                      Color>(
                                                  Color.fromARGB(
                                                      255, 255, 129, 101)),
                                          minHeight: 6.h, // 게이지바의 높이를 조정합니다.
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0.w),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text(
                                              textList[index],
                                              style: TextStyle(
                                                fontSize: 20.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 0.2.h,
                                      right: 0.2.w,
                                      child: IconButton(
                                        icon: Icon(
                                          bookmarkList[index]
                                              ? Icons.bookmark
                                              : Icons.bookmark_outline_sharp,
                                          color: bookmarkList[index]
                                              ? const Color(0xFFF26647)
                                              : Colors.grey[400],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            bookmarkList[index] =
                                                !bookmarkList[index];
                                          });
                                          updateBookmarkStatus(
                                              idList[index],
                                              bookmarkList[
                                                  index]); // 북마크 상태 서버에 업데이트
                                        },
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: LinearProgressIndicator(
                                          value: cardScoreList[index]
                                              .toDouble(), // 현재 값 / 최대 값
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                      Color>(
                                                  Color.fromARGB(
                                                      255, 255, 129, 101)),
                                          minHeight: 6.h, // 게이지바의 높이를 조정합니다.
                                        ),
                                      ),
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
