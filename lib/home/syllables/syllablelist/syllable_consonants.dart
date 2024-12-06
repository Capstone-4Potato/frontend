import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/home/fetchlearningcardlist.dart';
import 'package:flutter_application_1/home/syllables/syllabelearningcard.dart';
import 'package:flutter_application_1/ttsservice.dart';

// ignore: must_be_immutable
class SyllableConsonants extends StatefulWidget {
  SyllableConsonants({
    super.key,
    required this.category,
    required this.subcategory,
    required this.title,
  });
  String category;
  String subcategory;
  String title;

  @override
  State<SyllableConsonants> createState() => _SyllableConsonantsState();
}

class _SyllableConsonantsState extends State<SyllableConsonants> {
  // 학습 카드 정보들을 저장하는 리스트 변수들
  late List<int> cardIds = [];
  late List<String> contents = [];
  late List<String> pronunciations = [];
  late List<String> engpronunciations = [];
  late List<double> cardScores = [];
  late List<bool> bookmarked = [];
  late List<bool> weakCards = [];
  late List<String> explanations = [];
  late List<String> pictures = [];
  // 북마크된 카드만 표시할지 여부를 결정하는 변수
  bool showBookmarkedOnly = false;

  @override
  void initState() {
    super.initState();
    initFetch(); // 초기 데이터를 불러오는 함수 호출
  }

  // 데이터를 서버에서 불러와서 각 리스트 변수에 저장하는 함수
  void initFetch() async {
    var data = await fetchData(widget.category, widget.subcategory);

    if (data != null) {
      setState(() {
        // 서버에서 불러온 데이터를 각 변수에 할당
        cardIds = List.generate(data.length, (index) => data[index]['id']);
        contents = List.generate(data.length, (index) => data[index]['text']);
        pronunciations = List.generate(
            data.length, (index) => '${data[index]['engTranslation']}');
        engpronunciations = List.generate(
            data.length, (index) => '[${data[index]['engPronunciation']}]');
        bookmarked =
            List.generate(data.length, (index) => data[index]['bookmark']);
        cardScores = List.generate(
            data.length, (index) => data[index]['cardScore'] / 100.0);
        weakCards =
            List.generate(data.length, (index) => data[index]['weakCard']);
        explanations =
            List.generate(data.length, (index) => data[index]['explanation']);
        pictures =
            List.generate(data.length, (index) => data[index]['pictureUrl']);
      });
    }
  }

  // 학습 종료를 확인하는 다이얼로그를 표시하는 함수
  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height / 852;
        final double width = MediaQuery.of(context).size.width / 393;

        return ExitDialog(
          width: width,
          height: height,
          page: const MainPage(initialIndex: 0),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 화면에 표시할 카드 데이터를 저장하는 변수들
    List<int> displayCardIds = [];
    List<String> displayContents = [];
    List<String> displayPronunciations = [];
    List<String> displayEngPronunciations = [];
    List<double> displayCardScores = [];
    List<bool> displayBookmarked = [];
    List<bool> displayWeakCards = [];
    List<String> displayExplanations = [];
    List<String> displayPictures = [];
    // 북마크된 카드만 표시할지 여부에 따라 표시할 카드 데이터를 필터링
    if (showBookmarkedOnly) {
      for (int i = 0; i < cardIds.length; i++) {
        if (bookmarked[i]) {
          displayCardIds.add(cardIds[i]);
          displayContents.add(contents[i]);
          displayPronunciations.add(pronunciations[i]);
          displayEngPronunciations.add(engpronunciations[i]);
          displayCardScores.add(cardScores[i]);
          displayBookmarked.add(bookmarked[i]);
          displayWeakCards.add(weakCards[i]);
          displayExplanations.add(explanations[i]);
          displayPictures.add(pictures[i]);
        }
      }
    } else {
      // 북마크 필터가 적용되지 않은 경우 전체 카드 데이터를 사용
      displayCardIds = cardIds;
      displayContents = contents;
      displayPronunciations = pronunciations;
      displayEngPronunciations = engpronunciations;
      displayCardScores = cardScores;
      displayBookmarked = bookmarked;
      displayWeakCards = weakCards;
      displayExplanations = explanations;
      displayPictures = pictures;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        centerTitle: true,
        actions: [
          // 북마크 필터 버튼
          IconButton(
            icon: Icon(
              showBookmarkedOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                showBookmarkedOnly = !showBookmarkedOnly;
              });
            },
          ),
          // 학습 종료 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 3.8, 0),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black,
                size: 30,
              ),
              onPressed: _showExitDialog,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: GridView.builder(
        padding: const EdgeInsets.all(15),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 6 / 4.3,
        ),
        itemCount: displayBookmarked.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // 학습 카드 선택 시, 해당 카드의 올바른 발음 음성 불러오고 해당 카드 화면으로 이동
              TtsService.fetchCorrectAudio(displayCardIds[index]).then((_) {
                print('Audio fetched and saved successfully.');
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SyllableLearningCard(
                    currentIndex: index,
                    cardIds: displayCardIds,
                    texts: displayContents,
                    translations: displayPronunciations,
                    engpronunciations: displayEngPronunciations,
                    explanations: displayExplanations,
                    pictures: displayPictures,
                    bookmarked: displayBookmarked,
                  ),
                ),
              );
            },
            child: Opacity(
              // 카드의 학습 완료 정도에 따라 투명도 조절
              opacity: displayCardScores[index] >= 1.0 ? 0.5 : 1.0,
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
                            displayContents[index],
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: displayWeakCards[index]
                                    ? const Color.fromARGB(236, 255, 85, 85)
                                    : Colors.black),
                          ),
                        ),
                        Text(displayEngPronunciations[index],
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    // 북마크 버튼
                    Positioned(
                      top: 0.2,
                      right: 0.2,
                      child: IconButton(
                        icon: Icon(
                          displayBookmarked[index]
                              ? Icons.bookmark
                              : Icons.bookmark_outline_sharp,
                          color: displayBookmarked[index]
                              ? const Color(0xFFF26647)
                              : Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            // 북마크 상태를 토글
                            displayBookmarked[index] =
                                !displayBookmarked[index];
                            bookmarked[cardIds.indexOf(displayCardIds[index])] =
                                displayBookmarked[index];
                          });
                          // 북마크 상태를 서버에 업데이트
                          updateBookmarkStatus(
                              displayCardIds[index], displayBookmarked[index]);
                        },
                      ),
                    ),
                    // 점수를 나타내는 프로그레스 바
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
