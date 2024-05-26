import 'package:flutter/material.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/review/word/initial_consonant_1.dart';
import 'package:flutter_application_1/review/word/initial_consonant_2.dart';
import 'package:flutter_application_1/review/word/initial_consonant_3.dart';
import 'package:flutter_application_1/review/word/initial_consonant_4.dart';
import 'package:flutter_application_1/review/word/initial_consonant_5.dart';
import 'package:flutter_application_1/review/word/initial_consonant_6.dart';
import 'package:flutter_application_1/review/word/initial_consonant_7.dart';
// import 'package:flutter_application_1/wordlist/word_consonants_1.dart';
// import 'package:flutter_application_1/wordlist/word_consonants_2.dart';
// import 'package:flutter_application_1/wordlist/word_consonants_3.dart';
// import 'package:flutter_application_1/wordlist/word_consonants_4.dart';
// import 'package:flutter_application_1/wordlist/word_consonants_5.dart';
// import 'package:flutter_application_1/wordlist/word_consonants_6.dart';
// import 'package:flutter_application_1/wordlist/word_consonants_7.dart';

class ReviewWordConsonantTab extends StatefulWidget {
  const ReviewWordConsonantTab({super.key});

  @override
  State<ReviewWordConsonantTab> createState() => _ReviewWordConsonantTabState();
}

class _ReviewWordConsonantTabState extends State<ReviewWordConsonantTab> {
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
        return _buildWordCard(context, CategoryLists.wordConsonants[index]);
      },
    );
  }

  Widget _buildWordCard(BuildContext context, String title) {
    final Map<String, Widget Function()> navigationMap = {
      CategoryLists.wordConsonants[0]: () => const ReviewIC1(),
      CategoryLists.wordConsonants[1]: () => const ReviewIC2(),
      CategoryLists.wordConsonants[2]: () => const ReviewIC3(),
      CategoryLists.wordConsonants[3]: () => const ReviewIC4(),
      CategoryLists.wordConsonants[4]: () => const ReviewIC5(),
      CategoryLists.wordConsonants[5]: () => const ReviewIC6(),
      CategoryLists.wordConsonants[6]: () => const ReviewIC7(),
    };

    return Card(
      elevation: 0,
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
                    fontSize: 25,
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
