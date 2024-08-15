import 'package:flutter/material.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants_1.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants_2.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants_3.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants_4.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants_5.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants_6.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_consonants_7.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_vowels_1.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_vowels_2.dart';
import 'package:flutter_application_1/home/syllables/syllablelist/syllable_vowels_3.dart';

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
      CategoryLists.syllableTitles[0]: () => const SyllableVowels1(),
      CategoryLists.syllableTitles[1]: () => const SyllableVowels2(),
      CategoryLists.syllableTitles[2]: () => const SyllableVowels3(),
      CategoryLists.syllableTitles[3]: () => const SyllableConsonants1(),
      CategoryLists.syllableTitles[4]: () => const SyllableConsonants2(),
      CategoryLists.syllableTitles[5]: () => const SyllableConsonants3(),
      CategoryLists.syllableTitles[6]: () => const SyllableConsonants4(),
      CategoryLists.syllableTitles[7]: () => const SyllableConsonants5(),
      CategoryLists.syllableTitles[8]: () => const SyllableConsonants6(),
      CategoryLists.syllableTitles[9]: () => const SyllableConsonants7(),
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
