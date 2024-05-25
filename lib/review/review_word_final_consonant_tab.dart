import 'package:flutter/material.dart';
import 'package:flutter_application_1/class.dart';
import 'package:flutter_application_1/review/wordlist/final_consonant_1.dart';
import 'package:flutter_application_1/review/wordlist/final_consonant_2.dart';
import 'package:flutter_application_1/review/wordlist/final_consonant_3.dart';
import 'package:flutter_application_1/review/wordlist/final_consonant_4.dart';
import 'package:flutter_application_1/review/wordlist/final_consonant_5.dart';
import 'package:flutter_application_1/review/wordlist/final_consonant_6.dart';
import 'package:flutter_application_1/review/wordlist/final_consonant_7.dart';

class ReviewWordFinalConsonantTab extends StatefulWidget {
  const ReviewWordFinalConsonantTab({super.key});

  @override
  State<ReviewWordFinalConsonantTab> createState() =>
      _ReviewWordFinalConsonantTabState();
}

class _ReviewWordFinalConsonantTabState
    extends State<ReviewWordFinalConsonantTab> {
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
      CategoryLists.wordFinalCosonants[0]: () => const ReviewFC1(),
      CategoryLists.wordFinalCosonants[1]: () => const ReviewFC2(),
      CategoryLists.wordFinalCosonants[2]: () => const ReviewFC3(),
      CategoryLists.wordFinalCosonants[3]: () => const ReviewFC4(),
      CategoryLists.wordFinalCosonants[4]: () => const ReviewFC5(),
      CategoryLists.wordFinalCosonants[5]: () => const ReviewFC6(),
      CategoryLists.wordFinalCosonants[6]: () => const ReviewFC7(),
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
