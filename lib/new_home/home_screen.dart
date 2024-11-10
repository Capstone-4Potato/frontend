import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/learninginfo/progress.dart';
import 'package:flutter_application_1/learninginfo/study_info_page.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_home/home_cards.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

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

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      var url = Uri.parse('$main_url/home');
      String? token = await getAccessToken();
      print('$token');

      // api 요청 함수
      Future<http.Response> makeRequest(String token) {
        var headers = <String, String>{
          'access': token,
          'Content-Type': 'application/json',
        };
        return http.get(url, headers: headers);
      }

      var response = await makeRequest(token!);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
        });
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh and retry the request
        print('Access token expired. Refreshing token...');

        // Refresh the token
        bool isRefreshed = await refreshAccessToken();

        if (isRefreshed) {
          // Retry request with new token
          print('Token refreshed successfully. Retrying request...');
          String? newToken = await getAccessToken();
          response = await http.get(url, headers: {
            'access': '$newToken',
            'Content-Type': 'application/json'
          });

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
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
            });
          } else {
            // Handle other response codes after retry if needed
            print(
                'Unhandled server response after retry: ${response.statusCode}');
            print(json.decode(response.body));
          }
        } else {
          print('Failed to refresh token. Please log in again.');
        }
      } else {
        // Handle other status codes
        print('Unhandled server response: ${response.statusCode}');

        print(json.decode(response.body));
      }
    } catch (e) {
      // Handle network request exceptions
      print("Error during the request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;

    // Swiper에 들어갈 위젯 리스트
    List<Widget> widgetList = [
      CustomHomeCard(
          boxColor: Colors.white,
          contents: ContentTodayCard(
            dailyWord: dailyWord,
            dailyWordPronunciation: dailyWordPronunciation,
          )),
      CustomHomeCard(
          boxColor: const Color.fromARGB(255, 242, 235, 227),
          contents: const ContentCustomCard()),
    ];

    return userLevel == null
        ? Center(
            child: CircularProgressIndicator(
            color: primary,
          ))
        : Column(
            children: [
              Container(
                color: primary,
                height: 60 * height, // appbar size
              ),
              Container(
                height: 700 * height,
                color: primary,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          // 캐릭터와 레벨
                          alignment: Alignment.topCenter,
                          height: 265 * height,
                          color: primary,
                          child: Stack(
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 101,
                                  backgroundColor:
                                      const Color.fromARGB(255, 242, 235, 227),
                                  child: Image.asset(
                                      'assets/image/bam_character.png'),
                                ),
                              ),
                              Center(
                                child: SimpleCircularProgressBar(
                                  size: 220,
                                  maxValue: userExperience! / levelExperience!,
                                  progressStrokeWidth: 6,
                                  backStrokeWidth: 6,
                                  progressColors: [
                                    progress_color,
                                  ],
                                  backColor: back_progress_color,
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0, vertical: 7.0),
                                      decoration: BoxDecoration(
                                        color: progress_color,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Text('Level $userLevel'),
                                    ),
                                    Container(
                                      height: 10 * height,
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
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.notifications,
                            color: bam,
                            size: 24,
                          ),
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
                            Icons.settings,
                            color: bam,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    DraggableScrollableSheet(
                      // 드래그 시트
                      initialChildSize: 401 / 665 * height,
                      minChildSize: 400 / 665 * height,
                      maxChildSize: 665 / 665 * height,
                      shouldCloseOnMinExtent: true,
                      expand: true,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 245, 245, 245),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 21.0),
                                    child: CustomHomeCard(
                                      boxColor: Colors.white,
                                      contents: ContentTodayGoal(
                                        weeklyAttendance:
                                            weeklyAttendance!.split(''),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 140 * height,
                                    width: 360,
                                    child: Swiper(
                                      viewportFraction: 0.95,
                                      scale: 0.9,
                                      autoplay: true,
                                      itemBuilder: (context, index) {
                                        return Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ), // 좌우 간격 추가
                                            child: widgetList[index]);
                                      },
                                      itemCount: widgetList.length,
                                      pagination: SwiperPagination(
                                        alignment: const Alignment(0, 1.5),
                                        builder: DotSwiperPaginationBuilder(
                                            activeColor: primary,
                                            color: const Color.fromARGB(
                                                255, 235, 235, 235),
                                            size: 9.0,
                                            space: 4.0),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 23.0),
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