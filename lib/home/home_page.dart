import 'package:flutter/material.dart';
import 'package:flutter_application_1/customsentence/start.dart';
import 'package:flutter_application_1/home/sentence_category.dart';
import 'package:flutter_application_1/home/syllable_category.dart';
import 'package:flutter_application_1/home/word_category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              title: '음절학습',
              subtitle: 'Learning Syllables',
              backgroundColor: Color(0xFFFE6E88),
              image: Image.asset(
                'assets/syllable_image.png',
                height: 80,
                width: 80,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SyllablesCategoryScreen()),
                );
              },
            ),
            CategoryCard(
              title: '단어학습',
              subtitle: 'Learning Words',
              backgroundColor: const Color(0xFF466CFF),
              image: Image.asset(
                'assets/word_image.png',
                height: 70,
                width: 70,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WordsCategoryScreen()),
                );
              },
            ),
            CategoryCard(
              title: '문장학습',
              subtitle: 'Learning Sentences',
              backgroundColor: const Color(0xFF3AB9FE),
              image: Image.asset(
                'assets/sentence_image.png',
                height: 80,
                width: 80,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SentencesCategoryScreen()),
                );
              },
            ),
            CategoryCard(
              title: '사용자 맞춤 문장학습',
              subtitle: 'Learning Custom Sentences',
              image: Image.asset(
                'assets/custom_sentence_image.png',
                height: 70,
                width: 70,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomSentenceScreen()),
                );
              },
              backgroundColor: const Color(0xFFE472F6),
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
