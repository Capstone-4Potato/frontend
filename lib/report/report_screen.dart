// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/icons/custom_icons.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_application_1/new/models/levels.dart';
import 'package:flutter_application_1/new/services/api/report_api.dart';
import 'package:flutter_application_1/new/services/api/weak_sound_api.dart';
import 'package:flutter_application_1/new/services/api/weak_sound_test_api.dart';
import 'package:flutter_application_1/new/utils/navigation_extension.dart';
import 'package:flutter_application_1/report/vulnerablesoundtest/re_test_page.dart';
import 'package:flutter_application_1/report/phonemes_class.dart';
import 'package:flutter_application_1/new/widgets/dialogs/previous_test_found_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.keys,
  });

  final Map<String, GlobalKey> keys;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? nickname;
  int? studyDays;
  int? totalLearned;
  double? accuracy;
  int? weeklyAverageCards;
  int? sundayCards;
  int? mondayCards;
  int? tuesdayCards;
  int? wednesdayCards;
  int? thursdayCards;
  int? fridayCards;
  int? saturdayCards;
  String? cardLevel;

  List<Map<String, dynamic>>? weakPhonemes = [];
  List<Map<String, dynamic>> initialConsonants = [];
  List<Map<String, dynamic>> vowels = [];
  List<Map<String, dynamic>> finalConsonants = [];
  List<int> addPhonemes = []; // 추가할 취약음소
  List<String> levelOptions =
      Levels.values.map((e) => e.levelName).toList(); // 레벨 리스트로 저장

  bool isLoading = true; // 로딩 중 표시

  int touchedIndex = -1; // 그래프 터치 index
  int maxCardValue = 0;

  late PageController pageController; // 페이지 컨트롤러 생성
  int _currentPageIndex = 0;
  String? _selectedLevel; // 선택 레벨 값

  Future<void>? _fetchPhonemeFuture;

  @override
  void initState() {
    super.initState();
    fetchReportData();
    _fetchPhonemeFuture = fetchPhoneme();
    pageController = PageController(initialPage: 0); // PageController 초기화
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
      _currentPageIndex == 0
          ? initialConsonants.length
          : _currentPageIndex == 1
              ? vowels.length
              : finalConsonants.length;
    });
  }

  /// report 화면 데이터 요청 함수
  void fetchReportData() {
    getReportDataRequest(
      onDataReceived: (data) {
        if (mounted) {
          setState(() {
            nickname = data['nickname'];
            studyDays = data['studyDays'];
            totalLearned = data['totalLearned'];
            accuracy = data['accuracy'].toDouble();
            weeklyAverageCards = data['weeklyAverageCards'];
            sundayCards = data['sundayCards'];
            mondayCards = data['mondayCards'];
            tuesdayCards = data['tuesdayCards'];
            wednesdayCards = data['wednesdayCards'];
            thursdayCards = data['thursdayCards'];
            fridayCards = data['fridayCards'];
            saturdayCards = data['saturdayCards'];
            maxCardValue = (getMaxCardValue().toDouble() ~/ 5) * 5 + 5;
            cardLevel = data['cardLevel'];
            _selectedLevel = cardLevel;

            // weakPhonemes 리스트 처리
            weakPhonemes = (data['weakPhonemes'] ?? [])
                .map<Map<String, dynamic>>((phoneme) => {
                      'rank': phoneme['rank'],
                      'phonemeId': phoneme['phonemeId'],
                      'phonemeText': phoneme['phonemeText'],
                    })
                .toList();
            isLoading = false;
          });
        }
      },
    );
  }

  int getMaxCardValue() {
    // weakPhonemes의 6~12번째 값을 가져오기
    List<int> values = [
      sundayCards!,
      mondayCards!,
      tuesdayCards!,
      wednesdayCards!,
      thursdayCards!,
      fridayCards!,
      saturdayCards!
    ];

    // 최댓값 계산
    return values.reduce((value, element) => value > element ? value : element);
  }

  // 모든 취약음소와 사용자가 가진 취약음소 여부 반환
  Future<void> fetchPhoneme() async {
    await getWeakSoundListRequest(
      onDataReceived: (data) {
        if (mounted) {
          setState(() {
            // data["type"] 별로 list 저장
            initialConsonants = data
                .where((item) => item['type'] == 'Initial Consonant')
                .cast<Map<String, dynamic>>()
                .toList();
            vowels = data
                .where((item) => item['type'] == 'Vowel')
                .cast<Map<String, dynamic>>()
                .toList();
            finalConsonants = data
                .where((item) => item['type'] == 'Final Consonant')
                .cast<Map<String, dynamic>>()
                .toList();
          });
        }
      },
    );
  }

  // 취약음소 서버에 추가
  Future<void> postAddPhonemes() async {
    await addWeakSoundRequest(
      addPhonemes,
      onSuccess: () {
        if (mounted) {
          setState(() {
            addPhonemes.clear(); // 요청 성공 후 리스트 초기화
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    double width = MediaQuery.of(context).size.width / 392;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 모든 입력 필드 포커스 해제
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 10.h,
          backgroundColor: background,
          scrolledUnderElevation: 0,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF26647)),
              ))
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 25.0.w, right: 25.0.w, bottom: 50.0.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Hello,\n',
                              style: TextStyle(fontSize: 16.h),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '$nickname 👋',
                                  style: TextStyle(
                                    fontSize: 24.h,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor:
                                  const Color.fromARGB(255, 242, 235, 227),
                              child: SvgPicture.asset(
                                ImagePath.balbamCharacter5.path,
                                width: 50.h,
                                height: 50.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        key: widget.keys['reportAnalysisItemKey'],
                        padding: EdgeInsets.only(top: 24.0.h),
                        child: Wrap(
                          spacing: 45.w,
                          children: [
                            AnalysisItem(
                              icon: '🕰️',
                              title: 'Study Days',
                              value: studyDays!,
                              unit: 'days',
                            ),
                            AnalysisItem(
                              icon: '📖',
                              title: 'Learned',
                              value: totalLearned!,
                              unit: '',
                            ),
                            AnalysisItem(
                              icon: '👍',
                              title: 'Accuracy',
                              value: accuracy!,
                              unit: '%',
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 26.0.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Weekly Average",
                              style: TextStyle(
                                fontSize: 15.h,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFBEBDB8),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    text: '$weeklyAverageCards ',
                                    style: TextStyle(
                                      fontSize: 24.h,
                                      color: const Color(0xFF5E5D58),
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'cards',
                                        style: TextStyle(
                                          fontSize: 15.h,
                                          color: const Color(0xFFBEBDB8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 15.h,
                            ),
                            AspectRatio(
                              aspectRatio: 382 / 265,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 27.0.h),
                                child: BarChart(
                                  weeklyData(maxCardValue),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Course Level',
                            style: TextStyle(
                              color: const Color(0xFF5E5D58),
                              fontSize: 15.h,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 6.0.h, bottom: 6.0.h),
                            child: DropdownButton2<String>(
                              value: _selectedLevel!,
                              buttonStyleData: ButtonStyleData(
                                width: double.infinity,
                                height: 35.0.h,
                                padding:
                                    EdgeInsets.only(left: 10.0.w, right: 11.w),
                                decoration: BoxDecoration(
                                    color: AppColors.appBarColor,
                                    borderRadius: BorderRadius.circular(10.0.r),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1.0.w, // 테두리 너비
                                    )),
                                elevation: 0,
                              ),
                              alignment: AlignmentDirectional.centerStart,
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 223, 234, 251),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                elevation: 1,
                              ),
                              underline: const SizedBox(),
                              style: TextStyle(
                                color: bam,
                                fontSize: 12.h,
                              ),
                              items: levelOptions.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0.h),
                                    child: Text(entry),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                setState(() {
                                  _selectedLevel = value ?? 'Beginner';
                                });
                                await updateCardLevelRequest(value!);
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 22.0.h),
                            child: Text(
                              'This level will be reflected in the Today\'s Course card level.',
                              style: TextStyle(
                                color: const Color(0xFFBEBDB8),
                                fontSize: 12.h,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        key: widget.keys['vulnerablePhonemesKey'],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vulnerable Phonemes',
                            style: TextStyle(
                              color: const Color(0xFF5E5D58),
                              fontSize: 15.h,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0.h),
                            child: TextButton.icon(
                              onPressed: () async {
                                fetchPhoneme();

                                showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                          builder: (context, setDialogState) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0.r),
                                          ),
                                          insetPadding: EdgeInsets.symmetric(
                                              horizontal: 20.0.w,
                                              vertical: 130.0.h),
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF5F5F5),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight: Radius.circular(
                                                          16.0.r),
                                                      topLeft: Radius.circular(
                                                          16.0.r),
                                                    )),
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 32.0.h,
                                                      right: 27.0.w,
                                                      left: 27.0.w),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // 왼쪽 화살표
                                                      IconButton(
                                                        icon: const Icon(Icons
                                                            .arrow_back_ios),
                                                        onPressed:
                                                            _currentPageIndex >
                                                                    0
                                                                ? () {
                                                                    if (_currentPageIndex >
                                                                            0 &&
                                                                        _currentPageIndex <
                                                                            phonemes.length) {
                                                                      pageController
                                                                          .animateToPage(
                                                                        _currentPageIndex -
                                                                            1,
                                                                        duration:
                                                                            const Duration(milliseconds: 300),
                                                                        curve: Curves
                                                                            .easeInOut,
                                                                      );
                                                                      setDialogState(
                                                                          () {
                                                                        _currentPageIndex -=
                                                                            1;
                                                                      });
                                                                    }
                                                                  }
                                                                : null, // 첫 번째 페이지일 경우 비활성화
                                                      ),
                                                      // 카테고리 이름
                                                      Text(
                                                        phonemes[
                                                                _currentPageIndex]
                                                            .name,
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF282722),
                                                          fontSize: 20.h,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      // 오른쪽 화살표
                                                      IconButton(
                                                          icon: const Icon(Icons
                                                              .arrow_forward_ios),
                                                          onPressed:
                                                              _currentPageIndex <
                                                                      phonemes.length -
                                                                          1
                                                                  ? () {
                                                                      if (_currentPageIndex >=
                                                                              0 &&
                                                                          _currentPageIndex <
                                                                              phonemes.length) {
                                                                        pageController
                                                                            .animateToPage(
                                                                          _currentPageIndex +
                                                                              1,
                                                                          duration:
                                                                              const Duration(milliseconds: 300),
                                                                          curve:
                                                                              Curves.easeInOut,
                                                                        );
                                                                        setDialogState(
                                                                            () {
                                                                          _currentPageIndex +=
                                                                              1;
                                                                        });
                                                                      }
                                                                    }
                                                                  : null),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              FutureBuilder<void>(
                                                future: _fetchPhonemeFuture,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    // 로딩 상태
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    // 에러 상태
                                                    return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'),
                                                    );
                                                  } else {
                                                    return Expanded(
                                                      child: PageView.builder(
                                                        controller:
                                                            pageController,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(), // 스와이프 방지
                                                        onPageChanged: (index) {
                                                          _onPageChanged(index);
                                                        },
                                                        itemCount:
                                                            phonemes.length,
                                                        itemBuilder:
                                                            ((context, index) {
                                                          var category =
                                                              phonemes[index];

                                                          final currentList =
                                                              _currentPageIndex ==
                                                                      0
                                                                  ? initialConsonants
                                                                  : _currentPageIndex ==
                                                                          1
                                                                      ? vowels
                                                                      : finalConsonants;

                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFF5F5F5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        16.0.r),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        16.0.r),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          27.0
                                                                              .w,
                                                                      vertical:
                                                                          22.0.h),
                                                              child: Column(
                                                                children: [
                                                                  Expanded(
                                                                    child: GridView.builder(
                                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                          crossAxisCount:
                                                                              2, // 행당 아이템 수
                                                                          crossAxisSpacing:
                                                                              20.0.h, // 열 간격
                                                                          mainAxisSpacing:
                                                                              20.0.w, // 행 간격
                                                                          childAspectRatio:
                                                                              138.h / 88.h, // 가로:세로 비율
                                                                        ),
                                                                        itemCount: currentList.length,
                                                                        itemBuilder: (context, index) {
                                                                          // 리스트 길이 검증
                                                                          if (index >=
                                                                              currentList.length) {
                                                                            return const SizedBox.shrink();
                                                                          }

                                                                          return Material(
                                                                            color: currentList[index]['weak'] || addPhonemes.contains(currentList[index]['id'])
                                                                                ? const Color(0xFFDADADA)
                                                                                : Colors.white,
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.0.r),
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                setDialogState(() {
                                                                                  if (currentList[index]['weak']) {
                                                                                    null;
                                                                                  } else if (!addPhonemes.contains(currentList[index]['id'])) {
                                                                                    addPhonemes.add(currentList[index]['id']); // 선택된 인덱스 추가
                                                                                    weakPhonemes!.add(currentList[index]); // 취약음소 목록에 추가
                                                                                  } else {
                                                                                    addPhonemes.remove(currentList[index]['id']);
                                                                                    weakPhonemes!.remove(currentList[index]); // 취약음소 목록에서 제거
                                                                                  }
                                                                                });
                                                                                debugPrint('선택된 인덱스: $addPhonemes');
                                                                              },
                                                                              borderRadius: BorderRadius.circular(12.0.r),
                                                                              child: Container(
                                                                                alignment: Alignment.center,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(12.0.r),
                                                                                  border: Border.all(
                                                                                    color: currentList[index]['weak'] || addPhonemes.contains(currentList[index]['id']) ? Colors.transparent : const Color(0xFFF26647),
                                                                                  ),
                                                                                ),
                                                                                child: Text(
                                                                                  currentList[index]['text'] ?? 'N/A',
                                                                                  style: TextStyle(
                                                                                    fontSize: 32.h,
                                                                                    color: const Color(0xFF282722),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 12.0.h),
                                                child: TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoading = true; // 로딩 시작
                                                    });
                                                    try {
                                                      await postAddPhonemes(); // POST 요청 보내기
                                                      fetchReportData();
                                                    } catch (e) {
                                                      debugPrint(
                                                          'Error while adding phonemes: $e');
                                                    } finally {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    }
                                                    if (!isLoading) {
                                                      debugPrint(
                                                          "$weakPhonemes");
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFF26647),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.r),
                                                    ),
                                                    fixedSize:
                                                        const Size.fromWidth(
                                                            double.maxFinite),
                                                  ),
                                                  child: Text(
                                                    'Add',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20.h,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF5E5D58),
                                backgroundColor: const Color(0xFFF2EBE3),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 5.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0.r),
                                ),
                                surfaceTintColor: Colors.transparent,
                              ),
                              icon: Text(
                                '+',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF5E5D58),
                                  fontSize: 24.h,
                                ),
                              ),
                              label: Text(
                                'Add phonemes',
                                style: TextStyle(
                                  fontSize: 13.h,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              weakPhonemes!.isEmpty
                                  ? Container(
                                      padding: EdgeInsets.all(30.0.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2EBE3),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'You got no data for your vulnerable phonemes.\nTry out pronunciation test below!',
                                          style: TextStyle(
                                            color: const Color(0xFF5E5D58),
                                            fontSize: 13.h,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(top: 12.0.h),
                                      child: Column(
                                        children: List.generate(
                                          weakPhonemes!.length,
                                          (index) {
                                            String phonemeText =
                                                weakPhonemes![index]
                                                        ['phonemeText'] ??
                                                    '';
                                            List<String> parts =
                                                phonemeText.split(" ");

                                            return VulnerableCardItem(
                                              index: index,
                                              phonemes: parts.isNotEmpty
                                                  ? parts.last
                                                  : '',
                                              title: parts.length > 1
                                                  ? parts
                                                      .sublist(
                                                          0, parts.length - 1)
                                                      .join(' ')
                                                  : '',
                                              phonemeId: weakPhonemes![index]
                                                      ['phonemeId'] as int? ??
                                                  0, // 🔹 null이면 기본값 0 설정
                                              onDelete: () {
                                                setState(() {
                                                  weakPhonemes!.removeAt(
                                                      index); // 리스트에서 항목 삭제
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                              Padding(
                                padding: EdgeInsets.only(top: 12.0.h),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      bool check =
                                          await getUnfinishedTestRequest(); // 이전에 진행하던 테스트가 있는지 체크
                                      !check
                                          ? showPreviousTestFoundDialog(context)
                                          : context.navigateTo(
                                              screen: RestartTestScreen(
                                              check: check,
                                            ));
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      fixedSize: const Size.fromWidth(
                                          double.maxFinite),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 3.h,
                                      ),
                                      child: Text(
                                        'Pronunciation Test',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.h,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// 차트 그리기
  BarChartData weeklyData(int maxCardValue) {
    return BarChartData(
      maxY: maxCardValue.toDouble(),
      minY: 0,
      alignment: BarChartAlignment.center,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFFF2EBE3),
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: 10,
          tooltipRoundedRadius: 4.0,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              (rod.toY).toInt().toString(),
              const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' cards',
                  style: TextStyle(
                    color: const Color(0xFF92918C), //widget.touchedBarColor,
                    fontSize: 10.h,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 30.h,
            interval: 1,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30.w,
            interval: (maxCardValue / 5).toDouble(),
            getTitlesWidget: (value, meta) {
              return Container(
                padding: EdgeInsets.only(left: 10.w),
                child: Text(value.toInt().toString(),
                    style: TextStyle(
                      color: const Color(0xFFBEBDB8),
                      fontSize: 15.h,
                      fontWeight: FontWeight.w400,
                    )),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      barGroups: showingGroups(),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: const Color(0xFFD8D7D6),
        ),
      ),
      gridData: FlGridData(
        show: true,
        horizontalInterval: maxCardValue / 5,
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xFFD8D7D6),
          strokeWidth: 1.h,
          dashArray: [1, 1],
        ),
        verticalInterval: 1 / 7,
        getDrawingVerticalLine: (value) => FlLine(
          color: const Color(0xFFD8D7D6),
          strokeWidth: 1.h,
          dashArray: [1, 1],
        ),
      ),
      extraLinesData: ExtraLinesData(
        extraLinesOnTop: false,
        horizontalLines: [
          HorizontalLine(
            y: weeklyAverageCards!.toDouble(),
            color: weeklyAverageCards!.toDouble() == 0
                ? Colors.transparent
                : const Color(0xFFF26647),
            strokeWidth: 1.0.w,
          )
        ],
      ),
    );
  }

  /// 가로 축 title 정의
  Widget getTitles(double value, TitleMeta meta) {
    // x 축 text style
    final style = TextStyle(
      color: const Color(0xFF5E5D58),
      fontWeight: FontWeight.w400,
      fontSize: 12.h,
    );
    List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];

    Widget text = Text(
      days[value.toInt()],
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10.h, // 축과 text 간 공간
      child: text,
    );
  }

  /// 막대 스타일 지정
  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          // 막대 안쪽 색깔
          color: y > 0 // 값이 0 보다 크면 기본 색
              ? x == DateTime.now().weekday % 7
                  ? const Color(0xFFF26647) // 오늘 요일은 주황색
                  : const Color(0xFFF9C6A9)
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(3.r),
            topRight: Radius.circular(3.r),
          ),
          width: 30.w,
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, sundayCards!.toDouble(),
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, mondayCards!.toDouble(),
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, tuesdayCards!.toDouble(),
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, wednesdayCards!.toDouble(),
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, thursdayCards!.toDouble(),
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, fridayCards!.toDouble(),
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, saturdayCards!.toDouble(),
                isTouched: i == touchedIndex);

          default:
            return throw Error();
        }
      });
}

/// 취약음 랭킹 한 행씩 나타내는 위젯
class VulnerableCardItem extends StatelessWidget {
  VulnerableCardItem({
    super.key,
    required this.index,
    required this.phonemes,
    required this.title,
    required this.phonemeId,
    required this.onDelete,
  });

  int index;
  String phonemes;
  String title;
  int phonemeId;

  VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${index + 1}',
                style: TextStyle(
                  color: const Color(0xFFEDCAA8),
                  fontWeight: FontWeight.bold,
                  fontSize: 15.h,
                ),
              ),
              Text(
                phonemes,
                style: TextStyle(
                  color: bam,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.h,
                ),
              ),
              Container(
                width: 195.w,
                color: Colors.transparent,
                child: Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF5E5D58),
                    fontSize: 15.h,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await deleteWeakSoundRequest(phonemeId, onDelete: onDelete);
                },
                child: Container(
                  height: 27.h,
                  width: 27.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEBE9),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Icon(
                    CustomIcons.cancelIcon,
                    color: const Color(0xFF92918C),
                    size: 12.h,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 11.0.h),
          child: SizedBox(
            width: 343.w,
            height: 1.h,
            child: CustomPaint(
              painter: DottedLineHorizontalPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Study time, Learned, Accuracy 등 수치 항목을 나타내는 위젯
// ignore: must_be_immutable
class AnalysisItem extends StatelessWidget {
  AnalysisItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  String icon;
  String title;
  var value;
  String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: const Color.fromARGB(255, 242, 235, 227),
          child: Text(
            icon,
            style: TextStyle(
              fontSize: 28.h,
            ),
          ),
        ),
        SizedBox(
          height: 9.h,
        ),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF5E5D58),
            fontSize: 15.h,
          ),
        ),
        Text.rich(
          TextSpan(
            text: '$value',
            style: TextStyle(
              fontSize: 24.h,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5E5D58),
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  fontSize: 12.h,
                  color: const Color(0xFFBEBDB8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ## 수평 점선 Custom Painter (horizontal dotted line) 클래스 생성
class DottedLineHorizontalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8D7D6)
      ..strokeWidth = 1.w
      ..style = PaintingStyle.stroke;

    const dashWidth = 1;
    const dashSpace = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
