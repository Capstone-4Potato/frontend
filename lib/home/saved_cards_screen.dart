import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/learning_coures/sentecnes/sentencelearningcard.dart';
import 'package:flutter_application_1/learning_coures/words/wordlearningcard.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class SavedCardScreen extends StatefulWidget {
  const SavedCardScreen({
    super.key,
  });

  @override
  State<SavedCardScreen> createState() => _SavedCardScreenState();
}

class _SavedCardScreenState extends State<SavedCardScreen>
    with SingleTickerProviderStateMixin {
  List<int> idList = [];
  List<String> textList = [];
  List<String> cardPronunciationList = [];
  List<int> cardScoreList = [];
  List<bool> weakCardList = [];
  List<bool> bookmarkList = [];
  List<String> translationList = [];
  List<String> explanationList = [];
  List<String> pictureList = [];

  bool isLoading = true;

  late TabController _tabController;

  Future<void> fetchSavedCardList() async {
    try {
      String? token = await getAccessToken();
      var url = Uri.parse('$main_url/home/bookmark');

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
          List<Map<String, dynamic>> tempDataList = [];

          List<Future> futures = [];

          for (var card in cardList) {
            futures.add(fetchData(card['id']).then((cardData) async {
              await Future.delayed(const Duration(seconds: 1)); // 1초 대기
              tempDataList.add({
                'id': card['id'],
                'text': card['text'],
                'cardPronunciation': card['cardPronunciation'],
                'cardScore': card['cardScore'],
                ...cardData, // Merge additional data fetched from fetchData
              });
            }));
          }
          print(cardList);

          await Future.wait(futures);

          if (mounted) {
            setState(() {
              // 리스트 초기화
              idList.clear();
              textList.clear();
              cardScoreList.clear();
              weakCardList.clear();
              bookmarkList.clear();
              translationList.clear();
              explanationList.clear();
              pictureList.clear();

              // 변수 리스트에 데이터 저장
              for (var card in cardList) {
                idList.add(card['id']);
                textList.add(card['text']);
                cardPronunciationList.add(card['cardPronunciation']);
                cardScoreList.add(card['cardScore']);
                pictureList.add(card['pictureUrl'] ?? '');
                explanationList.add(card['explanation'] ?? '');
                translationList.add(card['cardTranslation'] ?? '');
                bookmarkList.add(card['bookmarked']);
                weakCardList.add(card['weakCard']);
              }
              isLoading = false;
            });
          }
        }
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
            var data = json.decode(response.body);
            List<dynamic> cardList = data['cardList'];

            if (mounted) {
              List<dynamic> tempDataList = [];

              List<Future> futures = [];

              for (var entry in cardList) {
                for (var card in entry) {
                  futures.add(fetchData(card['id']).then((cardData) async {
                    await Future.delayed(const Duration(seconds: 1)); // 1초 대기
                    tempDataList.add({
                      'id': card['id'],
                      'text': card['text'],
                      'cardPronunciation': card['cardPronunciation'],
                      'cardScore': card['cardScore'],
                      ...cardData, // Merge additional data fetched from fetchData
                    });
                  }));
                }
              }

              await Future.wait(futures);

              if (mounted) {
                setState(() {
                  // 리스트 초기화
                  idList.clear();
                  textList.clear();
                  cardScoreList.clear();
                  weakCardList.clear();
                  bookmarkList.clear();
                  translationList.clear();
                  explanationList.clear();
                  pictureList.clear();

                  // 변수 리스트에 데이터 저장
                  for (var card in cardList) {
                    idList.add(card['id']);
                    textList.add(card['text']);
                    cardPronunciationList.add(card['cardPronunciation']);
                    cardScoreList.add(card['cardScore']);
                    pictureList.add(card['pictureUrl'] ?? '');
                    explanationList.add(card['explanation'] ?? '');
                    translationList.add(card['cardTranslation'] ?? '');
                    bookmarkList.add(card['bookmarked']);
                    weakCardList.add(card['weakCard']);
                  }
                  isLoading = false;
                });
              }
            }
          }
        }
      } else if (response.statusCode == 500) {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> fetchData(int id) async {
    Map<String, dynamic> result = {};
    try {
      String? token = await getAccessToken();
      var url = Uri.parse('$main_url/cards/$id');

      var response = await http.get(url, headers: {
        'access': token!,
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        result = {
          'pictureUrl': data['pictureUrl'] ?? '',
          'explanation': data['explanation'] ?? '',
          'cardTranslation': data['cardTranslation'] ?? '',
          'bookmark': data['bookmark'],
          'weakCard': data['weakCard'],
        };
      } else if (response.statusCode == 401) {
        // Handle token refresh
        bool isRefreshed = await refreshAccessToken();
        if (isRefreshed) {
          token = await getAccessToken();
          response = await http.get(url, headers: {
            'access': token!,
            'Content-Type': 'application/json',
          });

          if (response.statusCode == 200) {
            var data = json.decode(response.body);
            result = {
              'pictureUrl': data['pictureUrl'] ?? '',
              'explanation': data['explanation'] ?? '',
              'cardTranslation': data['cardTranslation'] ?? '',
              'bookmark': data['bookmark'],
              'weakCard': data['weakCard'],
            };
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    fetchSavedCardList();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // id가 1684보다 작은 카드들만 필터링
    List<int> tab1Indices = idList
        .asMap()
        .entries
        .where((entry) => entry.value < 1684)
        .map((entry) => entry.key)
        .toList();

    List<int> tab1Ids = tab1Indices.map((index) => idList[index]).toList();
    List<String> tab1Texts =
        textList.where((id) => idList[textList.indexOf(id)] < 1684).toList();
    List<String> tab1Pronunciations = cardPronunciationList
        .where((id) => idList[cardPronunciationList.indexOf(id)] < 1684)
        .toList();
    List<int> tab1Scores = cardScoreList
        .where((id) => idList[cardScoreList.indexOf(id)] < 1684)
        .toList();
    List<bool> tab1WeakCards = weakCardList
        .where((id) => idList[weakCardList.indexOf(id)] < 1684)
        .toList();
    List<bool> tab1Bookmarks = bookmarkList
        .where((id) => idList[bookmarkList.indexOf(id)] < 1684)
        .toList();
    List<String> tab1Translations = translationList
        .where((id) => idList[translationList.indexOf(id)] < 1684)
        .toList();
    List<String> tab1Explanations = explanationList
        .where((id) => idList[explanationList.indexOf(id)] < 1684)
        .toList();
    List<String> tab1Pictures = pictureList
        .where((id) => idList[pictureList.indexOf(id)] < 1684)
        .toList();

    // id가 1684 이상인 카드들만 필터링
// Indices for id >= 1684
    List<int> tab2Indices = idList
        .asMap()
        .entries
        .where((entry) => entry.value >= 1684)
        .map((entry) => entry.key)
        .toList();

// Filter other lists using indices
    List<int> tab2Ids = tab2Indices.map((index) => idList[index]).toList();
    List<String> tab2Texts =
        tab2Indices.map((index) => textList[index]).toList();
    List<String> tab2Pronunciations =
        tab2Indices.map((index) => cardPronunciationList[index]).toList();
    List<int> tab2Scores =
        tab2Indices.map((index) => cardScoreList[index]).toList();
    List<bool> tab2WeakCards =
        tab2Indices.map((index) => weakCardList[index]).toList();
    List<bool> tab2Bookmarks =
        tab2Indices.map((index) => bookmarkList[index]).toList();
    List<String> tab2Translations =
        tab2Indices.map((index) => translationList[index]).toList();
    List<String> tab2Explanations =
        tab2Indices.map((index) => explanationList[index]).toList();
    List<String> tab2Pictures =
        tab2Indices.map((index) => pictureList[index]).toList();

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
          'Saved Cards',
          style: TextStyle(
            color: bam,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelColor: primary,
          tabs: const [
            Tab(text: 'Syllables & Words'),
            Tab(text: 'Sentences'),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Cards with id < 1684
                tab1Ids.isEmpty
                    ? const Center(child: Text('There is no Bo Cards!'))
                    : GridView.builder(
                        padding: EdgeInsets.all(15.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.w,
                          mainAxisSpacing: 15.w,
                          childAspectRatio: 6 / 4.3,
                        ),
                        itemCount: tab1Ids.length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildCard(
                              tab1Ids,
                              tab1Texts,
                              tab1Pronunciations,
                              tab1Translations,
                              tab1Explanations,
                              tab1Pictures,
                              tab1Scores,
                              tab1WeakCards,
                              tab1Bookmarks,
                              index);
                        },
                      ),
                // Tab 2: Cards with id >= 1684
                tab2Ids.isEmpty
                    ? const Center(child: Text('There is no Saved Cards!'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 15.w,
                          mainAxisSpacing: 15.w,
                          childAspectRatio: 3.3 / 1,
                        ),
                        itemCount: tab2Ids.length,
                        itemBuilder: (BuildContext context, int index) {
                          print(tab2Texts);
                          return buildCard(
                              tab2Ids,
                              tab2Texts,
                              tab2Pronunciations,
                              tab2Translations,
                              tab2Explanations,
                              tab2Pictures,
                              tab2Scores,
                              tab2WeakCards,
                              tab2Bookmarks,
                              index);
                        },
                      ),
              ],
            ),
    );
  }

  Widget buildCard(
      List<int> ids,
      List<String> texts,
      List<String> pronunciations,
      List<String> translations,
      List<String> explanations,
      List<String> pictures,
      List<int> scores,
      List<bool> weakCards,
      List<bool> bookmarks,
      int index) {
    return GestureDetector(
      onTap: () {
        // Fetch and save the correct audio for the selected card
        TtsService.fetchCorrectAudio(ids[index]).then((_) {
          print('Audio fetched and saved successfully.');
        });
        if (ids[index] >= 1684) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SentenceLearningCard(
                currentIndex: index,
                cardIds: ids,
                texts: texts,
                pronunciations: translations,
                engpronunciations: pronunciations,
                bookmarked: bookmarks,
              ),
            ),
          ).then((updatedBookmark) {
            if (updatedBookmark != null) {
              setState(() {
                bookmarks[index] = updatedBookmark;
              });
            }
          });
        } else if (ids[index] < 1684) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordLearningCard(
                currentIndex: index,
                cardIds: ids,
                texts: texts,
                translations: translations,
                explanations: explanations,
                pictures: pictures,
                engpronunciations: pronunciations,
                bookmarked: bookmarks,
              ),
            ),
          ).then((updatedBookmark) {
            if (updatedBookmark != null) {
              setState(() {
                bookmarks[index] = updatedBookmark;
              });
            }
          });
        }
      },
      child: Opacity(
        // 카드의 학습 완료 정도에 따라 투명도 조절
        opacity: scores[index] >= 100.0 ? 0.5 : 1.0,
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: (ids[index] >= 1684) // 문장이 아닌 단어이면
              ? Stack(
                  children: [
                    // 카드의 내용 표시
                    SizedBox(
                      width: 360.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              texts[index],
                              style: TextStyle(
                                  fontSize: 20.h,
                                  fontWeight: FontWeight.bold,
                                  color: weakCards[index] // 취약음이면
                                      ? const Color.fromARGB(236, 255, 85, 85)
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
                          bookmarks[index]
                              ? Icons.bookmark
                              : Icons.bookmark_border_sharp,
                          color: bookmarks[index]
                              ? const Color(0xFFF26647)
                              : Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            bookmarks[index] = !bookmarks[index];
                          });
                          updateBookmarkStatus(
                              ids[index], bookmarks[index]); // 북마크 상태 서버에 업데이트
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                          value: scores[index].toDouble(), // 현재 값 / 최대 값
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 255, 129, 101)),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              texts[index],
                              style: TextStyle(
                                color: weakCards[index]
                                    ? const Color.fromARGB(236, 255, 85, 85)
                                    : Colors.black,
                                fontSize: 20.h,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            '[${pronunciations[index]}]',
                            style: TextStyle(fontSize: 18.h),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0.2.h,
                      right: 0.2.w,
                      child: IconButton(
                        icon: Icon(
                          bookmarks[index]
                              ? Icons.bookmark
                              : Icons.bookmark_outline_sharp,
                          color: bookmarks[index]
                              ? const Color(0xFFF26647)
                              : Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            bookmarks[index] = !bookmarks[index];
                          });
                          updateBookmarkStatus(idList[index],
                              bookmarks[index]); // 북마크 상태 서버에 업데이트
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                          value: scores[index].toDouble() / 100, // 현재 값 / 최대 값
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 255, 129, 101)),
                          minHeight: 6.h, // 게이지바의 높이를 조정합니다.
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
