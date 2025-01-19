import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 프로필에서 튜토리얼 다시 보는 페이지
class RetutorialScreen extends StatefulWidget {
  const RetutorialScreen({super.key});

  @override
  _RetutorialScreenState createState() => _RetutorialScreenState();
}

class _RetutorialScreenState extends State<RetutorialScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  final List<String> _images = [
    'assets/tutorial/tutorial1.png',
    'assets/tutorial/tutorial2.png',
    'assets/tutorial/tutorial3.png',
    'assets/tutorial/tutorial4.png',
    'assets/tutorial/tutorial5.png',
    'assets/tutorial/tutorial6.png',
    'assets/tutorial/tutorial7.png',
    'assets/tutorial/tutorial8.png',
    'assets/tutorial/tutorial9.png',
    'assets/tutorial/tutorial10.png', // 마지막 이미지
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7A7A7A),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => escapeTutorial(context),
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
          Positioned(
            top: 55.h,
            left: 0,
            right: 0,
            child: Center(
              child: TabPageSelector(
                controller: _tabController,
                color: const Color.fromARGB(255, 188, 188, 188),
                selectedColor: primary,
                borderStyle: BorderStyle.none,
              ),
            ),
          ),
        ],
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
              // 메인화면으로 이동
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeNav()),
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
