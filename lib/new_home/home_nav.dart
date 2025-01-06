import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/icons/custom_icons.dart';
import 'package:flutter_application_1/learninginfo/study_info_page.dart';
import 'package:flutter_application_1/new_learning_coures/learning_course_card_list.dart';
import 'package:flutter_application_1/new_learning_coures/learning_course_screen.dart';
import 'package:flutter_application_1/new_today_course/fetch_today_course.dart';
import 'package:flutter_application_1/new_home/home_screen.dart';
import 'package:flutter_application_1/new_today_course/today_course_screen.dart';
import 'package:flutter_application_1/new_report/report_screen.dart';
import 'package:flutter_application_1/profile/tutorial/home_tutorial_screen1.dart';
import 'package:flutter_application_1/profile/tutorial/home_tutorial_screen2.dart';
import 'package:flutter_application_1/profile/tutorial/home_tutorial_screen3.dart';
import 'package:flutter_application_1/profile/tutorial/report_tutorial_screen1.dart';
import 'package:flutter_application_1/profile/tutorial/report_tutorial_screen2.dart';
import 'package:flutter_application_1/widgets/success_dialog.dart';
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
    'reportAnalysisItemKey': GlobalKey(),
    'vulnerablePhonemesKey': GlobalKey(),
  };
  late List<Widget> _screens; // 화면 리스트를 초기화
  int homeTutorialStep = 1; // 홈 화면 튜토리얼 단계 상태
  int reportTutorialStep = 1; // report 튜토리얼 단계 상태

  late bool checkTodayCourse; // todayCourse 했는지 체크 여부

  @override
  void initState() {
    super.initState();
    _loadTutorialStatus(); // 튜토리얼 완료 상태를 불러오기
    _loadCheckTodayCourse();

    // 초기 화면 세팅
    _screens = ([
      HomeScreen(keys: keys), // GlobalKey 전달
      ReportScreen(keys: keys),
    ]);
  }

  // SharedPreferences에서 튜토리얼 진행 상태를 불러오는 함수
  _loadTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      homeTutorialStep =
          prefs.getInt('homeTutorialStep') ?? 1; // 기본값은 1 (첫 번째 단계)

      reportTutorialStep =
          prefs.getInt('reportTutorialStep') ?? 1; // 기본값은 1 (첫 번째 단계)
    });
  }

  // SharedPreferences에서 todayCourse 했는지 여부
  _loadCheckTodayCourse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checkTodayCourse = prefs.getBool('checkTodayCourse') ?? true;
    });
  }

  // SharedPreferences에 튜토리얼 완료 상태 저장
  _completeTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (widget.bottomNavIndex == 0) {
      await prefs.setInt('homeTutorialStep', 4); // 4로 설정하여 홈 화면 튜토리얼 완료 표시
    }
    if (widget.bottomNavIndex == 1) {
      await prefs.setInt('reportTutorialStep', 3); // 4로 설정하여 레포트 화면 튜토리얼 완료 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    List<IconData> iconList = [
      CustomIcons.home_icon,
      CustomIcons.report_icon,
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
              icon: Icon(
                CustomIcons.todaycourse_icon,
                size: 44.sp,
              ),
              color: Colors.white,
              onPressed: () {
                checkTodayCourse
                    ? showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return SuccessDialog(
                            title: "Great!",
                            subtitle:
                                'You have already completed TodayCourse! Try again tomorrow.',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const LearningCourseScreen(),
                                ),
                              );
                            },
                            buttonText: "Go to\nLearning Course",
                          );
                        },
                      )
                    : Navigator.push<void>(
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
                  SizedBox(
                    height: 15.h,
                  ),
                  Icon(
                    iconList[index],
                    size: 20.sp,
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
            leftCornerRadius: 10.r,
            rightCornerRadius: 10.r,
            onTap: (index) => setState(() => widget.bottomNavIndex = index),
            backgroundColor: const Color.fromARGB(255, 242, 235, 227),
          ),
        ),

        // 튜토리얼 화면을 표시하는 조건
        if (widget.bottomNavIndex == 0 && homeTutorialStep == 1)
          // PostFrameCallback을 사용하여 레이아웃 완료 후 튜토리얼 표시
          LayoutBuilder(
            builder: (context, constraints) {
              // 한 프레임 지연 후 튜토리얼 표시
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {}); // 강제 리빌드
              });
              return HomeTutorialScreen1(
                keys: keys,
                onTap: () {
                  setState(() {
                    homeTutorialStep = 2;
                  });
                },
              );
            },
          ),
        if (widget.bottomNavIndex == 0 && homeTutorialStep == 2)
          HomeTutorialScreen2(
            keys: keys,
            onTap: () {
              setState(() {
                homeTutorialStep = 3; // 2단계 끝나면 3단계로
              });
            },
          ),
        if (widget.bottomNavIndex == 0 && homeTutorialStep == 3)
          HomeTutorialScreen3(
            keys: keys,
            onTap: () {
              setState(() {
                homeTutorialStep = 4; // 3단계 끝나면 4단계로
              });
              _completeTutorial(); // 튜토리얼 완료 시 호출
            },
          ),
        if (widget.bottomNavIndex == 1 && reportTutorialStep == 1)
          // PostFrameCallback을 사용하여 레이아웃 완료 후 튜토리얼 표시
          LayoutBuilder(
            builder: (context, constraints) {
              // 한 프레임 지연 후 튜토리얼 표시
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {}); // 강제 리빌드
              });
              return ReportTutorialScreen1(
                keys: keys,
                onTap: () {
                  setState(() {
                    reportTutorialStep = 2;
                  });
                },
              );
            },
          ),
        if (widget.bottomNavIndex == 1 && reportTutorialStep == 2)
          ReportTutorialScreen2(
            keys: keys,
            onTap: () {
              setState(() {
                reportTutorialStep = 3; // 2단계 끝나면 3단계로
                _completeTutorial(); // 튜토리얼 완료 시 호출
              });
            },
          ),
      ],
    );
  }
}
