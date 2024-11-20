import 'package:flutter/material.dart';
import 'package:flutter_application_1/new_home/new_custom/customsentence_page.dart';
import 'package:flutter_application_1/home/sentecnes/sentence_category.dart';
import 'package:flutter_application_1/home/syllables/syllable_category.dart';
import 'package:flutter_application_1/home/words/word_category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
              backgroundColor: const Color(0xFFFE6E88),
              image: Image.asset(
                'assets/syllable_image.png',
                height: screenHeight * 0.1, // 10% of screen height
                width: screenWidth * 0.2, // 20% of screen width
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SyllablesCategoryScreen()),
                );
              },
            ),
            CategoryCard(
              title: '단어학습',
              subtitle: 'Learning Words',
              backgroundColor: const Color(0xFF466CFF),
              image: Image.asset(
                'assets/word_image.png',
                height: screenHeight * 0.09, // 9% of screen height
                width: screenWidth * 0.18, // 18% of screen width
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WordsCategoryScreen()),
                );
              },
            ),
            CategoryCard(
              title: '문장학습',
              subtitle: 'Learning Sentences',
              backgroundColor: const Color(0xFF3AB9FE),
              image: Image.asset(
                'assets/sentence_image.png',
                height: screenHeight * 0.1, // 10% of screen height
                width: screenWidth * 0.2, // 20% of screen width
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SentencesCategoryScreen()),
                );
              },
            ),
            CategoryCard(
              title: '사용자 맞춤 문장학습',
              subtitle: 'Learning Custom Sentences',
              backgroundColor: const Color(0xFFE472F6),
              image: Image.asset(
                'assets/custom_sentence_image.png',
                height: screenHeight * 0.09, // 9% of screen height
                width: screenWidth * 0.18, // 18% of screen width
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomSentenceScreen()),
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
    // Get the screen width and height
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizes for text
    double responsiveTitleFontSize = screenWidth * 0.045;
    double responsiveSubtitleFontSize = screenWidth * 0.04;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal:
            screenWidth * 0.05, // 5% of screen width for horizontal margin
        vertical:
            screenHeight * 0.01, // 1% of screen height for vertical margin
      ),
      padding: EdgeInsets.symmetric(
        horizontal:
            screenWidth * 0.04, // 4% of screen width for horizontal padding
        vertical:
            screenHeight * 0.016, // 2% of screen height for vertical padding
      ),
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
                  style: TextStyle(
                    fontSize: responsiveSubtitleFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: responsiveTitleFontSize,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          screenWidth * 0.04, // Responsive horizontal padding
                    ),
                    minimumSize: Size(
                      screenWidth * 0.22, // Responsive minimum width
                      screenHeight * 0.045, // Responsive minimum height
                    ),
                    elevation: 2.0,
                  ),
                  child: Text(
                    'Start',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045, // Responsive font size
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: image,
          ),
        ],
      ),
    );
  }
}
