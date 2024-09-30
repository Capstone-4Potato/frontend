import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/home/fetchlearningcardlist.dart';
import 'package:flutter_application_1/home/sentecnes/sentencelearningcard.dart';
import 'package:flutter_application_1/ttsservice.dart';

class Sentence extends StatefulWidget {
  Sentence({
    super.key,
    required this.category,
    required this.subcategory,
    required this.title,
  });

  String category;
  String subcategory;
  String title;

  @override
  State<Sentence> createState() => _SentenceState();
}

class _SentenceState extends State<Sentence> {
  late List<int> cardIds = [];
  late List<String> contents = [];
  late List<String> pronunciations = [];
  late List<String> engpronunciations = [];
  late List<double> cardScores = [];
  late List<bool> bookmarked = [];
  late List<bool> weakCards = [];

  bool showBookmarkedOnly = false;

  @override
  void initState() {
    super.initState();
    initFetch();
  }

  void initFetch() async {
    var data = await fetchData(widget.category, widget.subcategory);
    if (data != null) {
      setState(() {
        cardIds = List.generate(data.length, (index) => data[index]['id']);
        contents = List.generate(data.length, (index) => data[index]['text']);
        // pronunciations =
        //     List.generate(data.length, (index) => data[index]['pronunciation']);
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
      });
    }
  }

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
    List<int> displayCardIds = [];
    List<String> displayContents = [];
    List<String> displayPronunciations = [];
    List<String> displayEngPronunciations = [];
    List<double> displayCardScores = [];
    List<bool> displayBookmarked = [];
    List<bool> displayWeakCards = [];

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
        }
      }
    } else {
      displayCardIds = cardIds;
      displayContents = contents;
      displayPronunciations = pronunciations;
      displayEngPronunciations = engpronunciations;
      displayCardScores = cardScores;
      displayBookmarked = bookmarked;
      displayWeakCards = weakCards;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * 0.045,
          ),
          textAlign: TextAlign.center, // Center-align the text in the AppBar
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        centerTitle: true,
        actions: [
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
          crossAxisCount: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 4,
          childAspectRatio: 10 / 3.4,
        ),
        itemCount: displayBookmarked.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // Fetch and save the correct audio for the selected card
              TtsService.fetchCorrectAudio(cardIds[index]).then((_) {
                print('Audio fetched and saved successfully.');
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SentenceLearningCard(
                    currentIndex: index,
                    cardIds: displayCardIds,
                    contents: displayContents,
                    pronunciations: displayPronunciations,
                    engpronunciations: displayEngPronunciations,
                  ),
                ),
              );
            },
            child: Opacity(
              opacity: displayCardScores[index] >= 1.0
                  ? 0.5
                  : 1.0, // 점수가 100점일 경우 투명도를 50%로 설정

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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              displayContents[index],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Center(
                            child: Text(
                              displayEngPronunciations[index],
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                            displayBookmarked[index] =
                                !displayBookmarked[index];
                            // Update the main bookmarked list as well
                            bookmarked[cardIds.indexOf(displayCardIds[index])] =
                                displayBookmarked[index];
                          });

                          updateBookmarkStatus(
                              displayCardIds[index], displayBookmarked[index]);
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                          value: displayCardScores[index], // 현재 값 / 최대 값
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 255, 129, 101)),
                          minHeight: 6, // 게이지바의 높이를 조정합니다.
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
