import 'package:flutter/material.dart';
import 'package:flutter_application_1/vulnerablesoundtest/starting_teat_page.dart';

// 회원가입 -> 튜토리얼
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController(initialPage: 0);
  final List<String> _images = [
    'assets/tutorial1.png',
    'assets/tutorial2.png',
    'assets/tutorial3.png',
    'assets/tutorial4.png',
    'assets/tutorial5.png',
    'assets/tutorial6.png',
    'assets/tutorial7.png',
    'assets/tutorial8.png',
    'assets/tutorial9.png', // 마지막 이미지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          // 마지막 페이지일 경우 특별한 뷰를 생성
          if (index == _images.length - 1) {
            return buildLastPage(context, _images[index]);
          }
          return buildImagePage(_images[index]);
        },
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
                MaterialPageRoute(builder: (context) => StartTestScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfff26647),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              '  start  ',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Screen")),
      body: Center(child: Text("Welcome to the home screen!")),
    );
  }
}
