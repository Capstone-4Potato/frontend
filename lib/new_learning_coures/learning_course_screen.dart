import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_learning_coures/learning_course_card_list.dart';
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
  int? value = 0; // 선택된 ChoiceChip 인덱스

  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  // 각 Container에 대한 GlobalKey
  final GlobalKey _beginnerKey = GlobalKey();
  final GlobalKey _intermediateKey = GlobalKey();
  final GlobalKey _advancedKey = GlobalKey();

  // AppBar 아래 Header Container Key
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getLearningCourseList();
    _scrollController.addListener(() {
      _updateChoiceChipByScroll();
    });
  }

  @override
  void dispose() {
    // ScrollController 해제
    _scrollController.dispose();
    super.dispose();
  }

  void _updateChoiceChipByScroll() {
    final double offset = _scrollController.offset;

    final beginnerPosition = _getWidgetPosition(_beginnerKey);
    final intermediatePosition = _getWidgetPosition(_intermediateKey);
    final advancedPosition = _getWidgetPosition(_advancedKey);

    setState(() {
      if (offset >= advancedPosition) {
        value = 2; // Advanced
      } else if (offset >= intermediatePosition) {
        value = 1; // Intermediate
      } else {
        value = 0; // Beginner
      }
    });
  }

  double _getWidgetPosition(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(
          Offset.zero,
          ancestor: context.findRenderObject(),
        ) ??
        Offset.zero;
    return position.dy;
  }

  /// 특정 인덱스로 스크롤 이동 함수
  void _scrollToLevel(int index) {
    GlobalKey targetKey;

    switch (index) {
      case 0:
        targetKey = _beginnerKey;
        break;
      case 1:
        targetKey = _intermediateKey;
        break;
      case 2:
        targetKey = _advancedKey;
        break;
      default:
        return;
    }

    // 해당 GlobalKey의 RenderObject 위치 계산
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(
          Offset.zero,
          ancestor: context.findRenderObject(),
        ) ??
        Offset.zero;

    // AppBar 높이 계산 (직접 선언)
    const double appBarHeight = kToolbarHeight; // 기본 AppBar 높이

    // Header Container 높이 계산
    final headerRenderBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final headerHeight = headerRenderBox?.size.height ?? 0;

    // 스크롤 애니메이션 수행
    _scrollController.animateTo(
      position.dy +
          _scrollController.offset -
          appBarHeight -
          headerHeight -
          100.h,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// 레벨 별 학습 현황 조회
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
        scrolledUnderElevation: 0, // 스크롤 엘레베이션 0
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
            key: _headerKey,
            padding: EdgeInsets.only(top: 18.0.h, bottom: 15.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 8.w,
                  children: List<Widget>.generate(levels.length, (index) {
                    return ChoiceChip(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 2.h),
                      label: Container(
                        alignment: Alignment.center,
                        child: Text(
                          levels[index],
                          style: TextStyle(
                            color: value == index
                                ? Colors.white
                                : const Color(0xFF92918C),
                            fontSize: 12.h,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 12.h,
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
                          // value = selected ? index : value; // 선택된 상태 업데이트
                          value = index; // 선택된 상태 업데이트
                          _scrollToLevel(index);
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
                      ? SizedBox(
                          height: 500.h,
                          child: const Center(
                              child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFF26647)),
                          )),
                        )
                      : _units.isEmpty
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Center(child: Text('Server Error!')),
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
                                        key: index == 0 ? _beginnerKey : null,
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
                                    _units.sublist(4, 15).length,
                                    (index) {
                                      final unit = _units.sublist(4, 15)[index];
                                      return UnitItem(
                                        key: index == 0
                                            ? _intermediateKey
                                            : null,
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
                                    _units.sublist(15, 22).length,
                                    (index) {
                                      final unit =
                                          _units.sublist(15, 22)[index];
                                      return UnitItem(
                                        key: index == 0 ? _advancedKey : null,
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
                                    _units.sublist(22, 25).length,
                                    (index) {
                                      final unit =
                                          _units.sublist(22, 25)[index];
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

/// 유닛 학습 정도 보여주는 위젯
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0.w),
      child: completedNumber == 0 // 학습하지 않은 상태
          ? GestureDetector(
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => LearningCourseCardList(
                      level: id,
                      subTitle: subtitle,
                    ),
                  ),
                );
              },
              child: Container(
                height: title == "Conversation Practice" ||
                        title == "Tongue Twisters"
                    ? 77.h
                    : 96.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0.r),
                  border: Border.all(
                    color: const Color(0xFFBEBDB8),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 30.0.w, top: 15.0.h, bottom: 15.0.h, right: 20.0.w),
                  child: title == "Conversation Practice" ||
                          title == "Tongue Twisters"
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300.w,
                              child: Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF63625C),
                                  fontSize: 16.h,
                                  fontWeight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // 넘칠 경우 말줄임표 추가
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: const Color(0xFF666560),
                                fontSize: 24.h,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              width: 300.w,
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  color: const Color(0xFF63625C),
                                  fontSize: 16.h,
                                  fontWeight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // 넘칠 경우 말줄임표 추가
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            )
          : completedNumber == totalNumber // 학습 완료한 상태
              ? GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            LearningCourseCardList(
                          level: id,
                          subTitle: subtitle,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 96.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E6),
                      borderRadius: BorderRadius.circular(24.0.r),
                      border: Border.all(color: const Color(0xFFF26647)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30.0.w,
                              top: 15.0.h,
                              bottom: 15.0.w,
                              right: 20.0.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 24.h,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: 256.w,
                                child: Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 14.h,
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    // letterSpacing: -0.2,
                                  ),
                                  //maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis, // 넘칠 경우 말줄임표 추가
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 45.w,
                            height: 28.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF26647),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            LearningCourseCardList(
                          level: id,
                          subTitle: subtitle,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    // 학습 중인 상태
                    height: 116.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0.r),
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
                          padding: EdgeInsets.only(
                              left: 30.0.w,
                              top: 15.0.h,
                              bottom: 15.0.h,
                              right: 20.0.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 24.h,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: 256.w,
                                child: Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 14.h,
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    // letterSpacing: -0.2,
                                  ),
                                  //maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis, // 넘칠 경우 말줄임표 추가
                                ),
                              ),
                              Container(
                                height: 16.h,
                                width: 245.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBEBDB8),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                //alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: (completedNumber) /
                                          (totalNumber) *
                                          245.w,
                                      height: 16.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF26647),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.0.r),
                                          bottomLeft: Radius.circular(16.0.r),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 4.0.h,
                                            bottom: 8.0.h,
                                            left: 5.0.w,
                                            right: 4.0.w),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFB8A71),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16.0.r),
                                              bottomLeft:
                                                  Radius.circular(16.0.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '$completedNumber / $totalNumber',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.h,
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
                          width: 45.w,
                          height: double.maxFinite,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF26647),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(24.r),
                              bottomRight: Radius.circular(24.r),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 24.h,
                          ),
                        ),
                      ],
                    ),
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
