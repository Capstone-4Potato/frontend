import 'package:flutter/material.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/sentencelist/sentence_1.dart';
import 'package:flutter_application_1/sentencelist/sentence_2.dart';
import 'package:flutter_application_1/sentencelist/sentence_3.dart';
import 'package:flutter_application_1/sentencelist/sentence_4.dart';

class SentencesCategoryScreen extends StatefulWidget {
  const SentencesCategoryScreen({super.key});

  @override
  State<SentencesCategoryScreen> createState() =>
      _SentencesCategoryScreenState();
}

class _SentencesCategoryScreenState extends State<SentencesCategoryScreen> {
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
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Sentences',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        actions: [
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
      body: Container(
        child: GridView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: CategoryLists.sentenceTitles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 6,
            childAspectRatio: 10 / 2.5,
          ),
          itemBuilder: (context, index) {
            return _buildSyllableCard(
                context, CategoryLists.sentenceTitles[index]);
          },
        ),
      ),
    );
  }

  // _buildSyllableCard 함수를 수정하여 타이틀과 서브타이틀을 함께 표시합니다.
  Widget _buildSyllableCard(BuildContext context, String title) {
    final Map<String, Widget Function()> navigationMap = {
      CategoryLists.sentenceTitles[0]: () => const Sentence1(),
      CategoryLists.sentenceTitles[1]: () => const Sentence2(),
      CategoryLists.sentenceTitles[2]: () => const Sentence3(),
      CategoryLists.sentenceTitles[3]: () => const Sentence4(),
    };

    return Card(
      elevation: 0, // 그림자 제거
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xfff26647),
          width: 1.2,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        // InkWell을 사용하여 ListTile과 비슷한 탭 효과를 구현할 수 있습니다.
        onTap: () {
          if (navigationMap.containsKey(title)) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => navigationMap[title]!()),
            );
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff525252),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
