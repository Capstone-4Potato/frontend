import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/functions/show_common_dialog.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/icons/custom_icons.dart';
import 'package:flutter_application_1/home/home_cards.dart';
import 'package:flutter_application_1/new/services/api/home_api.dart';
import 'package:flutter_application_1/new/utils/calculate_last_login_days.dart';
import 'package:flutter_application_1/new/widgets/home_character.dart';
import 'package:flutter_application_1/notification/notification_screen.dart';
import 'package:flutter_application_1/settings/profile_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.keys,
  });

  final Map<String, GlobalKey> keys;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? userLevel; // 사용자 레벨
  int? levelExperience; // 레벨 총 경험치
  int? userExperience; // 사용자 경험치
  String? weeklyAttendance; // 사용자 출석
  int? dailyWordId; // 일일 단어 아이디
  String? dailyWord; // 일일 단어
  String? dailyWordPronunciation; // 일일 단어 발음
  int? savedCardNumber; // Saved Card 수
  int? missedCardNumber; // Missed Card 수
  int? customCardNumber; // Custom Card 수
  bool? hasUnreadNotifications; // 알림 읽음 여부
  String? lastLoginDate; // 마지막 로그인 날짜 (당일 제외)
  bool? checkTodayCourse; // today Course 했는지 여부

  double progressValue = 0;

  int homeTutorialStep = 1; // 홈 화면 튜토리얼 단계 상태

  int characterIndex = 4;

  @override
  void initState() {
    super.initState();
    _initializeHomeScreen(); // 홈 화면 초기화
  }

  // 초기화 함수
  Future<void> _initializeHomeScreen() async {
    await fetchHomeUserData(); // 홈 화면 정보 초기화
    await _loadTutorialStatus(); // 튜토리얼 진행 상황 초기화
    await _loadCheckTodayCourse(); // todayCourse 했는지 여부

    setState(() {
      characterIndex = determineCharacter(); // 모든 데이터가 로드된 후 캐릭터 설정
    });
  }

  // SharedPreferences에서 튜토리얼 진행 상태를 불러오는 함수
  _loadTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      homeTutorialStep =
          prefs.getInt('homeTutorialStep') ?? 1; // 기본값은 1 (첫 번째 단계)
    });

    if (homeTutorialStep == 4) {
      // welcom dialog 표시
      // ignore: use_build_context_synchronously
      showCommonDialog(context, dialogType: DialogType.welcome);
      prefs.setInt('homeTutorialStep', 5);
    }
  }

  Future<void> fetchHomeUserData() async {
    final data = await getHomeDataRequest();
    setState(() {
      userLevel = data['userLevel'];
      levelExperience = data['levelExperience'];
      userExperience = data['userExperience'];
      weeklyAttendance = data['weeklyAttendance'];
      dailyWordId = data['dailyWordId'];
      dailyWord = data['dailyWord'];
      dailyWordPronunciation = data['dailyWordPronunciation'];
      savedCardNumber = data['savedCardNumber'];
      missedCardNumber = data['missedCardNumber'];
      customCardNumber = data['customCardNumber'];
      hasUnreadNotifications = data['hasUnreadNotifications'];
      lastLoginDate = data['lastLoginDate'];
    });
  }

  // SharedPreferences에서 todayCourse 했는지 여부
  Future<void> _loadCheckTodayCourse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checkTodayCourse = prefs.getBool('checkTodayCourse') ?? false;
      debugPrint("check today course : $checkTodayCourse");
    });
  }

  int determineCharacter() {
    int loginDays = calculateLastLoginDays(lastLoginDate);
    // 읽지 않은 알림이 있는 경우
    if (hasUnreadNotifications!) {
      return 0;
    }
    // today's course 끝낸 경우
    else if (checkTodayCourse!) {
      return 1;
    }
    // 마지막 접속일 3일 경과
    else if (loginDays >= 3 && loginDays < 7) {
      return 2;
    }
    // 마지막 접속일 7일 경과
    else if (loginDays >= 7) {
      return 3;
    }
    // 기본값
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    // Swiper에 들어갈 위젯 리스트
    List<Widget> widgetList = [
      CustomHomeCard(
          boxColor: Colors.white,
          contents: ContentTodayCard(
            dailyWordId: dailyWordId,
            dailyWord: dailyWord,
            dailyWordPronunciation: dailyWordPronunciation,
          )),
      CustomHomeCard(
          boxColor: const Color.fromARGB(255, 242, 235, 227),
          contents: const ContentCustomCard()),
      CustomHomeCard(
        boxColor: const Color(0xFFDFEAFB),
        contents: const ContentLearningCourseCard(),
      ),
    ];

    return userLevel == null
        ? const Center(
            child: CircularProgressIndicator(
            color: AppColors.primary,
          ))
        : Column(
            children: [
              Container(
                color: AppColors.primary,
                height: 60.h, // appbar size
              ),
              Container(
                height: 700.h,
                color: AppColors.primary,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          // 캐릭터와 레벨
                          alignment: Alignment.topCenter,
                          height: 265.h,
                          color: AppColors.primary,
                          child: Stack(
                            children: [
                              Center(
                                child: CircleAvatar(
                                  key: widget.keys['avatarKey'],
                                  radius: 101.r,
                                  backgroundColor: AppColors.orange_001,
                                  child: HomeCharacter(
                                    characterIndex: characterIndex,
                                  ),
                                ),
                              ),
                              Center(
                                child: SimpleCircularProgressBar(
                                  key: widget.keys['progressbarKey'],
                                  size: 220.w,
                                  maxValue: levelExperience!.toDouble(),
                                  progressStrokeWidth: 6.w,
                                  backStrokeWidth: 6.w,
                                  progressColors: const [
                                    AppColors.orange_003,
                                  ],
                                  backColor: AppColors.circularAvatar_000,
                                  startAngle: 180,
                                  valueNotifier: ValueNotifier(
                                      userExperience!.toDouble()), // 진행 상태 연결
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      key: widget.keys['levelTagKey'],
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.0.w, vertical: 6.0.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.orange_003,
                                        borderRadius:
                                            BorderRadius.circular(25.r),
                                      ),
                                      child: Text(
                                        'Level $userLevel',
                                      ),
                                    ),
                                    Container(
                                      height: 10.h,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      // 상단 메뉴 아이콘들
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const NotificationScreen(),
                                  ),
                                ).then((updateHasUnreadNotification) {
                                  if (updateHasUnreadNotification != null) {
                                    setState(() {
                                      hasUnreadNotifications =
                                          !updateHasUnreadNotification;
                                      characterIndex =
                                          determineCharacter(); // 모든 데이터가 로드된 후 캐릭터 설정
                                    });
                                  }
                                });
                              },
                              icon: Icon(
                                CustomIcons.notification_icon,
                                color: AppColors.icon_001,
                                size: 20.sp,
                              ),
                            ),
                            if (hasUnreadNotifications!)
                              Positioned(
                                right: 10.w,
                                top: 12.h,
                                child: Container(
                                  width: 5.w,
                                  height: 5.h,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF2EBE3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const ProfilePage(),
                              ),
                            );
                          },
                          icon: Icon(
                            CustomIcons.setting_icon,
                            color: AppColors.icon_001,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    DraggableScrollableSheet(
                      // 드래그 시트
                      initialChildSize: (0.56).h,
                      minChildSize: (0.56).h,
                      // maxChildSize: (665 / 665).h,
                      shouldCloseOnMinExtent: true,
                      expand: true,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 245, 245, 245),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  topRight: Radius.circular(20.r),
                                ),
                              ),
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25.0.w, vertical: 21.0.h),
                                    child: CustomHomeCard(
                                      key: widget.keys['todayGoalKey'],
                                      boxColor: Colors.white,
                                      contents: ContentTodayGoal(
                                        weeklyAttendance:
                                            weeklyAttendance!.split(''),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    key: widget.keys['todayCardKey'],
                                    height: 140.h,
                                    width: 360.w,
                                    child: Swiper(
                                      viewportFraction: 0.95,
                                      scale: 0.9,
                                      autoplay: true,
                                      itemBuilder: (context, index) {
                                        return Container(
                                            margin: EdgeInsets.symmetric(
                                              vertical: 5.h,
                                            ), // 좌우 간격 추가
                                            child: widgetList[index]);
                                      },
                                      itemCount: widgetList.length,
                                      pagination: SwiperPagination(
                                        alignment: const Alignment(0, 1.5),
                                        builder: DotSwiperPaginationBuilder(
                                            activeColor: AppColors.icon_001,
                                            color: const Color.fromARGB(
                                                255, 235, 235, 235),
                                            size: 9.0.h,
                                            space: 4.0.h),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25.0.w, vertical: 23.0.h),
                                    child: CustomHomeCard(
                                      boxColor: Colors.white,
                                      contents: ContentTodayMenu(
                                        level: userLevel!,
                                        savedCardNumber: savedCardNumber!,
                                        missedCardNumber: missedCardNumber!,
                                        customCardNumber: customCardNumber!,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
