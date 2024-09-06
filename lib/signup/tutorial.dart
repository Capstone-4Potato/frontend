import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/vulnerablesoundtest/starting_test_page.dart';

// 회원가입 -> 튜토리얼
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  final List<String> _images = [
    'assets/tutorial/tutorial1.png',
    'assets/tutorial/tutorial2.png',
    'assets/tutorial/tutorial3.png',
    'assets/tutorial/tutorial4.png',
    'assets/tutorial/tutorial5.png',
    'assets/tutorial/tutorial6.png',
    'assets/tutorial/tutorial7.png',
    'assets/tutorial/tutorial8.png',
    'assets/tutorial/tutorial9.png', // 마지막 이미지
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _images.length, vsync: this);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _tabController.dispose();
  }

  void escapeTutorial(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StartTestScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 235, 227),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 235, 227),
        //backgroundColor: Colors.pink[200],
        title: TabPageSelector(
          controller: _tabController,
          color: const Color.fromARGB(255, 188, 188, 188),
          selectedColor: primary,
          borderStyle: BorderStyle.none,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          escapeTutorial(context);
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: _images.length,
          onPageChanged: (index) {
            _tabController.animateTo(index);
          },
          itemBuilder: (context, index) {
            // 마지막 페이지일 경우 특별한 뷰를 생성
            if (index == _images.length - 1) {
              return buildLastPage(context, _images[index]);
            }
            return buildImagePage(_images[index]);
          },
        ),
      ),
    );
  }

  Widget buildImagePage(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildLastPage(BuildContext context, String imagePath) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          right: 30,
          child: ElevatedButton(
            onPressed: () {
              // 취약음 테스트 페이지로 이동
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const StartTestScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff26647),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text(
              '  start  ',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }
}
