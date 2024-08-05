import 'package:flutter/material.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/home/fetchlearningcardlist.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/wordlearningcard.dart';

class WordConsonants7 extends StatefulWidget {
  const WordConsonants7({super.key});

  @override
  State<WordConsonants7> createState() => _WordConsonants7State();
}

class _WordConsonants7State extends State<WordConsonants7> {
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
    var data = await fetchData('단어', '자음ㅇㅎ');
    if (data != null) {
      setState(() {
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
      });
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("End Learning"),
          content: Text("Do you want to end learning?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: Text("Continue Learning"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: Text("End"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit the learning screen
                Navigator.of(context).pop();
                // Navigator.of(context).pop();
              },
            ),
          ],
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
          'ㅇㅎ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            // fontSize: 18,
            fontSize: 22,
          ),
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
              icon: Icon(
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
              // Fetch and save the correct audio for the selected card
              TtsService.fetchCorrectAudio(cardIds[index]).then((_) {
                print('Audio fetched and saved successfully.');
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordLearningCard(
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            displayContents[index],
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: displayWeakCards[index]
                                    ? Color.fromARGB(236, 255, 85, 85)
                                    : Colors.black),
                          ),
                        ),
                        Text(displayEngPronunciations[index],
                            style: TextStyle(fontSize: 18)),
                      ],
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
