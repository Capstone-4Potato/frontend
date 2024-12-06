import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_learning_coures/unit_class.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LearningCourseScreen extends StatefulWidget {
  const LearningCourseScreen({super.key});

  @override
  State<LearningCourseScreen> createState() => _LearningCourseScreenState();
}

class _LearningCourseScreenState extends State<LearningCourseScreen> {
  final List<Unit> _units = [];

  List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];
  int? value = 0;

  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getLearningCourseList();
  }

  /// 특정 인덱스로 스크롤 이동 함수
  void _scrollToIndex(int index) {
    // 컨트롤러가 연결되어 있는지 확인
    if (_scrollController.hasClients) {
      // 특정 섹션의 위치를 계산
      double offset;
      switch (index) {
        case 0:
          offset = 0;
          break;
        case 1:
          offset = 620.h;
          break;
        case 2:
          offset = 1500.h;
          break;
        default:
          offset = 0;
      }
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  //
  Future<void> _getLearningCourseList() async {
    String? token = await getAccessToken();
    String url = '$main_url/home/course';

    // 로딩 중
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'access': '$token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(response.body)['courseList'];
        setState(() {
          _units.addAll(
            responseData.map((data) => Unit.fromJson(data)).toList(),
          );
          isLoading = false;
          print(_units);
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
          final retryResponse = await http.get(
            Uri.parse(url),
            headers: <String, String>{
              'access': '$newToken',
              'Content-Type': 'application/json',
            },
          );

          if (retryResponse.statusCode == 200) {
            final List<dynamic> responseData =
                json.decode(retryResponse.body)['courseList'];
            setState(() {
              _units.addAll(
                responseData.map((data) => Unit.fromJson(data)).toList(),
              );
              isLoading = false;
            });
          } else {
            _showErrorDialog(
                'Failed to load Learning Course after retry. Please try again.');
          }
        } else {
          _showErrorDialog('Failed to refresh token. Please log in again.');
        }
      } else {
        _showErrorDialog('Failed to load Learning Course. Please try again.');
      }
    } catch (e) {
      // Handle network request exceptions
      print("Error during the request: $e");
      _showErrorDialog('Failed to load Learning Course. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please check your server state.'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2EBE3),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: bam,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: Text(
          'Learning Course',
          style: TextStyle(
            color: bam,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 8,
                  children: List<Widget>.generate(levels.length, (index) {
                    return ChoiceChip(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 2),
                      label: Container(
                        alignment: Alignment.center,
                        child: Text(
                          levels[index],
                          style: TextStyle(
                            color: value == index
                                ? Colors.white
                                : const Color(0xFF92918C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      selected: value == index,
                      selectedColor: value == index
                          ? const Color(0xFFF26647)
                          : Colors.white,
                      showCheckmark: false,
                      autofocus: true,
                      onSelected: (bool selected) {
                        setState(() {
                          value = index;
                          _scrollToIndex(index);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 21.0.h),
                    child: Center(
                      child: Text(
                        'Each unit is organized by pronunciation difficulty.\nStart with Unit 1 and move up as you improve!',
                        style: TextStyle(
                          color: const Color(0xFf92918C),
                          fontSize: 12.h,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFF26647)),
                        ))
                      : _units.isEmpty
                          ? const Column(
                              children: [
                                Center(
                                    child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFF26647)),
                                )),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LevelDivider(level: levels[0]),
                                SizedBox(
                                  height: 21.h,
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  spacing: 16,
                                  children: List<Widget>.generate(
                                    4,
                                    (index) {
                                      return UnitItem(
                                        id: _units[index].id,
                                        title: _units[index].title,
                                        subtitle: _units[index].subtitle,
                                        totalNumber: _units[index].totalNumber,
                                        completedNumber:
                                            _units[index].completedNumber,
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30.0),
                                  child: LevelDivider(level: levels[1]),
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  spacing: 16,
                                  children: List<Widget>.generate(
                                    _units.sublist(4, 11).length,
                                    (index) {
                                      final unit = _units.sublist(4, 11)[index];
                                      return UnitItem(
                                        id: unit.id,
                                        title: unit.title,
                                        subtitle: unit.subtitle,
                                        totalNumber: unit.totalNumber,
                                        completedNumber: unit.completedNumber,
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0, bottom: 24.0),
                                  child: LevelDivider(level: levels[2]),
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.only(left: 18.0, bottom: 17.0),
                                  child: Text(
                                    'Conversation Practice',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  spacing: 16,
                                  children: List<Widget>.generate(
                                    _units.sublist(11, 18).length,
                                    (index) {
                                      final unit =
                                          _units.sublist(11, 18)[index];
                                      return UnitItem(
                                        id: unit.id,
                                        title: unit.title,
                                        subtitle: unit.subtitle,
                                        totalNumber: unit.totalNumber,
                                        completedNumber: unit.completedNumber,
                                      );
                                    },
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(
                                      left: 18.0, top: 24.0, bottom: 17.0),
                                  child: Text(
                                    'Tongue Twisters',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  spacing: 16,
                                  children: List<Widget>.generate(
                                    _units.sublist(18, 25).length,
                                    (index) {
                                      final unit =
                                          _units.sublist(18, 25)[index];
                                      return UnitItem(
                                        id: unit.id,
                                        title: unit.title,
                                        subtitle: unit.subtitle,
                                        totalNumber: unit.totalNumber,
                                        completedNumber: unit.completedNumber,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UnitItem extends StatelessWidget {
  int id;
  String title;
  String subtitle;
  int totalNumber;
  int completedNumber;

  UnitItem({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.totalNumber,
    required this.completedNumber,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: completedNumber == 0 || completedNumber == totalNumber
          ? Container(
              height: 96 * height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: const Color(0xFFBEBDB8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, top: 15.0, bottom: 15.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                        ),
                        overflow: TextOverflow.ellipsis, // 넘칠 경우 말줄임표 추가
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              height: 116 * height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.17),
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 30.0, top: 15.0, bottom: 15.0, right: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: 256,
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              // letterSpacing: -0.2,
                            ),
                            //maxLines: 2,
                            overflow: TextOverflow.ellipsis, // 넘칠 경우 말줄임표 추가
                          ),
                        ),
                        Container(
                          height: 16 * height,
                          width: 245,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBEBDB8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          //alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Container(
                                width: (completedNumber) / (totalNumber) * 245,
                                height: 16 * height,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF26647),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    bottomLeft: Radius.circular(16.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0,
                                      bottom: 8.0,
                                      left: 5.0,
                                      right: 4.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFB8A71),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(16.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '$completedNumber / $totalNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 45,
                    height: double.maxFinite,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF26647),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class LevelDivider extends StatelessWidget {
  String level;

  LevelDivider({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 1.0,
              decoration: const BoxDecoration(
                color: Color(0xFFBEBDB8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              level,
              style: const TextStyle(
                color: Color(0xFFf26647),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Container(
                height: 1.0,
                //width: 145.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFBEBDB8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
