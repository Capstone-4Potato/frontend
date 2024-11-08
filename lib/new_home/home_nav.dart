import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/learninginfo/study_info_page.dart';
import 'package:flutter_application_1/new_home/fetch_today_course.dart';
import 'package:flutter_application_1/new_home/home_screen.dart';
import 'package:flutter_application_1/new_home/today_course_screen.dart';
import 'package:flutter_application_1/new_report/report_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({
    super.key,
  });

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> with TickerProviderStateMixin {
  var _bottomNavIndex = 0; // 네비게이션 바 인덱스

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 393;
    double height = MediaQuery.of(context).size.height / 852;

    List<IconData> iconList = [
      Icons.home,
      Icons.person_2,
    ];
    List<String> labelList = ['Home', 'Report'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: _screens[_bottomNavIndex], // 현재 선택된 화면을 표시
      floatingActionButton: Container(
        width: 98,
        height: 98,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.menu_book_outlined,
            size: 44,
          ),
          color: Colors.white,
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const TodayCourseScreen(),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (index, isActive) {
          final color = isActive ? primary : bam;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                iconList[index],
                size: 24,
                color: color,
              ),
              Text(
                labelList[index],
                style: TextStyle(color: color),
              ),
            ],
          );
        },
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.sharpEdge,
        leftCornerRadius: 10,
        rightCornerRadius: 10,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        backgroundColor: const Color.fromARGB(255, 242, 235, 227),
      ),
    );
  }
}
