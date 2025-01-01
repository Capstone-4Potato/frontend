import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/learninginfo/study_info_page.dart';
import 'package:flutter_application_1/new_today_course/fetch_today_course.dart';
import 'package:flutter_application_1/new_home/home_screen.dart';
import 'package:flutter_application_1/new_today_course/today_course_screen.dart';
import 'package:flutter_application_1/new_report/report_screen.dart';
import 'package:flutter_application_1/profile/tutorial/home_tutorial_screen1.dart';
import 'package:flutter_application_1/profile/tutorial/home_tutorial_screen2.dart';
import 'package:flutter_application_1/profile/tutorial/home_tutorial_screen3.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeNav extends StatefulWidget {
  HomeNav({
    super.key,
    this.bottomNavIndex = 0,
  });

  int bottomNavIndex; // 네비게이션 바 인덱스

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> with TickerProviderStateMixin {
  // GlobalKey를 Map으로 관리
  final Map<String, GlobalKey> keys = {
    'avatarKey': GlobalKey(),
    'progressbarKey': GlobalKey(),
    'levelTagKey': GlobalKey(),
    'todayGoalKey': GlobalKey(),
    'homeNavFabKey': GlobalKey(),
    'homeNavContainerKey': GlobalKey(),
    'todayCardKey': GlobalKey(),
  };
  late List<Widget> _screens; // 화면 리스트를 초기화
  int tutorialStep = 1; // 튜토리얼 단계 상태

  @override
  void initState() {
    super.initState();
    _loadTutorialStatus(); // 튜토리얼 완료 상태를 불러오기

    // 초기 화면 세팅
    _screens = ([
      HomeScreen(keys: keys), // GlobalKey 전달
      const ReportScreen(),
    ]);
  }

  // SharedPreferences에서 튜토리얼 진행 상태를 불러오는 함수
  _loadTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      tutorialStep = prefs.getInt('tutorialStep') ?? 1; // 기본값은 1 (첫 번째 단계)
    });
  }

  // SharedPreferences에 튜토리얼 완료 상태 저장
  _completeTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tutorialStep', 4); // 4로 설정하여 튜토리얼 완료 표시
  }

  @override
  Widget build(BuildContext context) {
    List<IconData> iconList = [
      Icons.home,
      Icons.person_2,
    ];
    List<String> labelList = ['Home', 'Report'];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          body: _screens[widget.bottomNavIndex], // 현재 선택된 화면을 표시
          floatingActionButton: Container(
            key: keys['homeNavFabKey'],
            width: 98.w,
            height: 98.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF26647),
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
                    builder: (BuildContext context) =>
                        const TodayCourseScreen(),
                  ),
                );
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            key: keys['homeNavContainerKey'],
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
            activeIndex: widget.bottomNavIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.sharpEdge,
            leftCornerRadius: 10,
            rightCornerRadius: 10,
            onTap: (index) => setState(() => widget.bottomNavIndex = index),
            backgroundColor: const Color.fromARGB(255, 242, 235, 227),
          ),
        ),

        // 튜토리얼 화면을 표시하는 조건
        if (widget.bottomNavIndex == 0 && tutorialStep == 1)
          HomeTutorialScreen1(
            keys: keys,
            onTap: () {
              setState(() {
                tutorialStep = 2; // 1단계 끝나면 2단계로
              });
            },
          ),
        if (widget.bottomNavIndex == 0 && tutorialStep == 2)
          HomeTutorialScreen2(
            keys: keys,
            onTap: () {
              setState(() {
                tutorialStep = 3; // 2단계 끝나면 3단계로
              });
            },
          ),
        if (widget.bottomNavIndex == 0 && tutorialStep == 3)
          HomeTutorialScreen3(
            keys: keys,
            onTap: () {
              _completeTutorial(); // 튜토리얼 완료 시 호출
            },
          ),
      ],
    );
  }
}
