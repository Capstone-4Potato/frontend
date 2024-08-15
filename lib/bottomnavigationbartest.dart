import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/home_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/review/review_page.dart';
import 'package:flutter_application_1/learninginfo/study_info_page.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  MainPage({this.initialIndex = 0});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  // 각 탭에 해당하는 페이지들 정의
  final List<Widget> _pages = [
    HomePage(),
    ReviewPage(),
    StudyInfoPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // 초기 탭 인덱스 설정
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 페이지 표시
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 항목 위치 고정
        backgroundColor: const Color(0xFFF5F5F5),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.autorenew),
            label: 'Review',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'LearningInfo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xfff26647),
        unselectedItemColor: const Color.fromARGB(255, 176, 173, 173),
        onTap: _onItemTapped,
      ),
    );
  }
}
