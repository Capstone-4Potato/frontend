//종성 탭 위젯

import 'package:flutter/material.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_1.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_2.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_3.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_4.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_5.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_6.dart';
import 'package:flutter_application_1/wordlist/word_final_consonants_7.dart';

class WordFinalConsonantTab extends StatefulWidget {
  const WordFinalConsonantTab({super.key});

  @override
  State<WordFinalConsonantTab> createState() => _WordFinalConsonantTabState();
}

class _WordFinalConsonantTabState extends State<WordFinalConsonantTab> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 6 / 4,
      ),
      itemBuilder: (context, index) {
        return _buildWordCard(context, CategoryLists.wordFinalCosonants[index]);
      },
    );
  }

  Widget _buildWordCard(BuildContext context, String title) {
    final Map<String, Widget Function()> navigationMap = {
      CategoryLists.wordFinalCosonants[0]: () => const WordFinalConsonants1(),
      CategoryLists.wordFinalCosonants[1]: () => const WordFinalConsonants2(),
      CategoryLists.wordFinalCosonants[2]: () => const WordFinalConsonants3(),
      CategoryLists.wordFinalCosonants[3]: () => const WordFinalConsonants4(),
      CategoryLists.wordFinalCosonants[4]: () => const WordFinalConsonants5(),
      CategoryLists.wordFinalCosonants[5]: () => const WordFinalConsonants6(),
      CategoryLists.wordFinalCosonants[6]: () => const WordFinalConsonants7(),
    };

    return Card(
      elevation: 0, // 그림자 제거
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xfff26647),
          width: 1.2,
        ),
      ),
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
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff525252),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
