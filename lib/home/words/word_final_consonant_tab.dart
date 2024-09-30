//종성 탭 위젯

import 'package:flutter/material.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/home/words/wordlist/word_final_consonants.dart';

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
      CategoryLists.wordFinalCosonants[0]: () =>
          WordFinalConsonants(category: '단어', subcategory: '받침ㄱ', title: 'ㄱ'),
      CategoryLists.wordFinalCosonants[1]: () =>
          WordFinalConsonants(category: '단어', subcategory: '받침ㄴ', title: 'ㄴ'),
      CategoryLists.wordFinalCosonants[2]: () =>
          WordFinalConsonants(category: '단어', subcategory: '받침ㄷ', title: 'ㄷ'),
      CategoryLists.wordFinalCosonants[3]: () =>
          WordFinalConsonants(category: '단어', subcategory: '받침ㄹ', title: 'ㄹ'),
      CategoryLists.wordFinalCosonants[4]: () =>
          WordFinalConsonants(category: '단어', subcategory: '받침ㅁ', title: 'ㅁ'),
      CategoryLists.wordFinalCosonants[5]: () =>
          WordFinalConsonants(category: '단어', subcategory: '받침ㅂ', title: 'ㅂ'),
      CategoryLists.wordFinalCosonants[6]: () =>
          WordFinalConsonants(category: '단어', subcategory: '받침ㅇ', title: 'ㅇ'),
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
