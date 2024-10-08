// 중성 탭 위젯

import 'package:flutter/material.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/home/words/wordlist/word_vowels.dart';

class WordVowelTab extends StatefulWidget {
  const WordVowelTab({super.key});

  @override
  State<WordVowelTab> createState() => _WordVowelTabState();
}

class _WordVowelTabState extends State<WordVowelTab> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 3,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 6 / 4,
      ),
      itemBuilder: (context, index) {
        return _buildWordCard(context, CategoryLists.wordVowels[index]);
      },
    );
  }

  Widget _buildWordCard(BuildContext context, String title) {
    final Map<String, Widget Function()> navigationMap = {
      CategoryLists.wordVowels[0]: () => WordVowels(
            category: '단어',
            subcategory: '단모음',
            title: 'ㅏㅓㅗㅜ ㅡ ㅣㅐㅔ',
          ),
      CategoryLists.wordVowels[1]: () => WordVowels(
            category: '단어',
            subcategory: '이중모음1',
            title: 'ㅑ ㅕ ㅛ ㅠ',
          ),
      CategoryLists.wordVowels[2]: () => WordVowels(
            category: '단어',
            subcategory: '이중모음2',
            title: 'ㅒㅖㅘㅙㅝㅞㅚㅟㅢ',
          ),
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
                    fontSize: 23,
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
