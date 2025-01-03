import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/home/sentecnes/sentencelearningcard.dart';
import 'package:flutter_application_1/home/sentecnes/tongue_twisters_learing_card.dart';
import 'package:flutter_application_1/home/syllables/syllabelearningcard.dart';
import 'package:flutter_application_1/home/words/wordlearningcard.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

/// 레벨 별로 학습 카드 목록 띄워주는 스크린
class LearningCourseCardList extends StatefulWidget {
  LearningCourseCardList({
    super.key,
    required this.level,
    required this.subTitle,
  });

  int level;
  String subTitle;

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

  /// 해당 레벨 카드리스트 불러오는 함수
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

            // Level 15 이하면 picktureUrl 이랑 explanation이 없음
            pictureUrlList.add(card['pictureUrl'] ?? '');
            explanationList.add(card['explanation'] ?? '');

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
          widget.subTitle,
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
          : GridView.builder(
              padding: EdgeInsets.all(15.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.level < 16 ? 2 : 1,
                crossAxisSpacing: widget.level < 16 ? 15.w : 12.w,
                mainAxisSpacing: widget.level < 16 ? 15.h : 4.h,
                childAspectRatio: widget.level < 16 ? 6 / 4.3 : 10 / 3.4,
              ),
              itemCount: idList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // 학습 카드 선택 시, 해당 카드의 올바른 발음 음성 불러오고 해당 카드 화면으로 이동
                    TtsService.fetchCorrectAudio(idList[index]).then((_) {
                      print('Audio fetched and saved successfully.');
                    });
                    // level 1 : 음절 학습 카드로 이동
                    if (widget.level == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SyllableLearningCard(
                            currentIndex: index,
                            cardIds: idList,
                            texts: textList,
                            translations: engTranslationList,
                            engpronunciations: engPronunciationList,
                            explanations: explanationList,
                            pictures: pictureUrlList,
                            bookmarked: bookmarkList,
                          ),
                        ),
                      ).then((updatedBookmark) {
                        if (updatedBookmark != null) {
                          setState(() {
                            bookmarkList[index] = updatedBookmark;
                          });
                        }
                      });
                    }
                    //  level 2~ 15 : 단어 학습 카드로 이동
                    else if (widget.level < 16) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WordLearningCard(
                            currentIndex: index,
                            cardIds: idList,
                            texts: textList,
                            translations: engTranslationList,
                            engpronunciations: engPronunciationList,
                            explanations: explanationList,
                            pictures: pictureUrlList,
                            bookmarked: bookmarkList,
                          ),
                        ),
                      ).then((updatedBookmark) {
                        if (updatedBookmark != null) {
                          setState(() {
                            bookmarkList[index] = updatedBookmark;
                          });
                        }
                      });
                    }
                    // level 16~ 22 : 문장 학습 카드로 이동
                    else if (widget.level < 23) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SentenceLearningCard(
                            currentIndex: index,
                            cardIds: idList,
                            texts: textList,
                            pronunciations: engTranslationList,
                            engpronunciations: engPronunciationList,
                            bookmarked: bookmarkList,
                          ),
                        ),
                      ).then((updatedBookmark) {
                        if (updatedBookmark != null) {
                          setState(() {
                            bookmarkList[index] = updatedBookmark;
                          });
                        }
                      });
                    }
                    // level 23 이상 : 잰말놀이 학습 카드로 이동
                    else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TongueTwistersLearningCard(
                            currentIndex: index,
                            cardIds: idList,
                            texts: textList,
                            pronunciations: engTranslationList,
                            engpronunciations: engPronunciationList,
                            bookmarked: bookmarkList,
                          ),
                        ),
                      ).then((updatedBookmark) {
                        if (updatedBookmark != null) {
                          setState(() {
                            bookmarkList[index] = updatedBookmark;
                          });
                        }
                      });
                    }
                  },
                  child: Opacity(
                    // 카드의 학습 완료 정도에 따라 투명도 조절
                    opacity: cardScoreList[index] >= 1.0 ? 0.5 : 1.0,
                    child: Card(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                        ),
                      ),
                      child: (widget.level < 16)
                          ? Stack(
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
                                            color: weakCardList[index] // 취약음이면
                                                ? const Color.fromARGB(
                                                    236, 255, 85, 85)
                                                : Colors.black),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      "[${engPronunciationList[index]}]",
                                      style: TextStyle(
                                        fontSize: 18.h,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
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
                                          const AlwaysStoppedAnimation<Color>(
                                              Color.fromARGB(
                                                  255, 255, 129, 101)),
                                      minHeight: 6, // 게이지바의 높이를 조정합니다.
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : // level이 16보다 크면
                          Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          textList[index],
                                          style: TextStyle(
                                              fontSize: 20.h,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  weakCardList[index] // 취약음이면
                                                      ? const Color.fromARGB(
                                                          236, 255, 85, 85)
                                                      : Colors.black),
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          engTranslationList[index],
                                          style: TextStyle(fontSize: 16.h),
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
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
                                          const AlwaysStoppedAnimation<Color>(
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
