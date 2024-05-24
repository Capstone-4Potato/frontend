import 'package:flutter/material.dart';
import 'package:flutter_application_1/review/review_sentence_category.dart';
import 'package:flutter_application_1/review/review_syllable_category.dart';
import 'package:flutter_application_1/review/review_word_category.dart';

class ReviewPage extends StatefulWidget {
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            CategoryCard(
              title: '음절복습',
              subtitle: 'Reviewing Syllables',
              backgroundColor: const Color(0xFFFF6F50),
              image: Image.asset(
                'assets/syllable_image.png',
                height: 80,
                width: 80,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ReviewSyllablesCategoryScreen()),
                );
              },
            ),
            CategoryCard(
              title: '단어복습',
              subtitle: 'Reviewing Words',
              backgroundColor: const Color(0xFF24C434),
              image: Image.asset(
                'assets/review_word_image.png',
                height: 70,
                width: 70,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReviewWordsCategoryScreen()),
                );
              },
            ),
            CategoryCard(
              title: '문장복습',
              subtitle: 'Reviewing Sentences',
              backgroundColor: const Color(0xFFFFB800),
              image: Image.asset(
                'assets/review_sentence_image.png',
                height: 80,
                width: 80,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ReviewSentencesCategoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final Widget image;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.onTap,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // 패딩 조절
                    minimumSize: Size(93, 32), elevation: 2.0,
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
          ),
          Align(
            // Align 위젯을 사용해 이미지를 오른쪽에 배치
            alignment: Alignment.centerRight, // 중앙 오른쪽에 배치
            child: image,
          ),
        ],
      ),
    );
  }
}
