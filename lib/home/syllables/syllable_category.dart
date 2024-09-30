import 'package:flutter/material.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/exit_dialog.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_vowels.dart';

class SyllablesCategoryScreen extends StatefulWidget {
  const SyllablesCategoryScreen({super.key});

  @override
  State<SyllablesCategoryScreen> createState() =>
      _SyllablesCategoryScreenState();
}

class _SyllablesCategoryScreenState extends State<SyllablesCategoryScreen> {
  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height / 852;
        final double width = MediaQuery.of(context).size.width / 393;

        return ExitDialog(width: width, height: height);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Syllables',
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
      body: Container(
        child: GridView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: CategoryLists.syllableTitles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 6 / 4,
          ),
          itemBuilder: (context, index) {
            return _buildSyllableCard(
                context,
                CategoryLists.syllableTitles[index],
                CategoryLists.syllableSubtitles[index]);
          },
        ),
      ),
    );
  }

  // _buildSyllableCard 함수를 수정하여 타이틀과 서브타이틀을 함께 표시합니다.
  Widget _buildSyllableCard(
      BuildContext context, String title, String subtitle) {
    final Map<String, Widget Function()> navigationMap = {
      CategoryLists.syllableTitles[0]: () => SyllableVowels(
          category: '음절', subcategory: '단모음', title: 'ㅏㅓㅗㅜ ㅡ ㅣㅐㅔ'),
      CategoryLists.syllableTitles[1]: () =>
          SyllableVowels(category: '음절', subcategory: '이중모음1', title: 'ㅑㅕㅛㅠ'),
      CategoryLists.syllableTitles[2]: () => SyllableVowels(
          category: '음절', subcategory: '이중모음2', title: 'ㅒㅖㅘㅙㅝㅞㅚㅟㅢ'),
      CategoryLists.syllableTitles[3]: () => SyllableConsonants(
          category: '음절', subcategory: '자음ㄱㅋㄲ', title: title),
      CategoryLists.syllableTitles[4]: () => SyllableConsonants(
          category: '음절', subcategory: '자음ㄷㅌㄸ', title: title),
      CategoryLists.syllableTitles[5]: () => SyllableConsonants(
          category: '음절', subcategory: '자음ㅂㅍㅃ', title: title),
      CategoryLists.syllableTitles[6]: () =>
          SyllableConsonants(category: '음절', subcategory: '자음ㅅㅆ', title: title),
      CategoryLists.syllableTitles[7]: () => SyllableConsonants(
          category: '음절', subcategory: '자음ㅈㅊㅉ', title: title),
      CategoryLists.syllableTitles[8]: () => SyllableConsonants(
          category: '음절', subcategory: '자음ㄴㄹㅁ', title: title),
      CategoryLists.syllableTitles[9]: () =>
          SyllableConsonants(category: '음절', subcategory: '자음ㅇㅎ', title: title),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff525252),
                  ),
                ),
                const SizedBox(height: 4), // 타이틀과 서브타이틀 사이의 공간을 추가합니다.
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(231, 171, 169, 169),
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
