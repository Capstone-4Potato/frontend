import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/new/models/colors.dart';
import 'package:flutter_application_1/report/report_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

/// 리포트 화면 튜토리얼 2
class ReportTutorialScreen2 extends StatelessWidget {
  const ReportTutorialScreen2({
    super.key,
    required this.keys,
    required this.onTap,
  });

  final Map<String, GlobalKey> keys;
  final VoidCallback onTap; // onTap 콜백 추가

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    List<Map<String, dynamic>>? weakPhonemes = [
      {"rank": 1, "phonemeId": 2, "phonemeText": 'Initial Consonant ㄴ'},
      {"rank": 2, "phonemeId": 22, "phonemeText": 'Vowel ㅜ'},
    ];

    // 렌더링된 후 위치와 크기를 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 취약 음소 상자 위치와 크기
      final RenderBox? vulnerablePhonemesRenderBox =
          keys['vulnerablePhonemesKey']?.currentContext?.findRenderObject()
              as RenderBox?;
      if (vulnerablePhonemesRenderBox != null) {
        final vulnerablePhonemesSize = vulnerablePhonemesRenderBox.size;
        final vulnerablePhonemesPosition =
            vulnerablePhonemesRenderBox.localToGlobal(Offset.zero);
      }
    });

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 반투명 배경
          Container(
            color: Colors.black.withOpacity(0.6),
            width: width,
            height: height,
          ),
          Builder(
            builder: (context) {
              // 취약음소 위치와 크기
              final RenderBox? vulnerablePhonemesRenderBox =
                  keys['vulnerablePhonemesKey']
                      ?.currentContext
                      ?.findRenderObject() as RenderBox?;

              if (vulnerablePhonemesRenderBox != null) {
                // 취약음소 위치와 크기
                final vulnerablePhonemesSize = vulnerablePhonemesRenderBox.size;
                final vulnerablePhonemesPosition =
                    vulnerablePhonemesRenderBox.localToGlobal(Offset.zero);

                return Stack(
                  children: [
                    // Vulnerable Phonemes Card
                    Positioned(
                      top: vulnerablePhonemesPosition.dy - 120.h,
                      left: 0, // 왼쪽부터 시작
                      right: 0, // 오른쪽까지 확장
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // 수직 방향 정렬 유지
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 가로 방향 중앙 정렬
                        children: [
                          DefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.h,
                                fontWeight: FontWeight.w500),
                            child: const Text(
                              'Try out pronuciation test to find out\nyour weak points & customize it freely!',
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                            width: 10.w,
                            height: 10.h,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            height: 40.h,
                            width: 0.1.w,
                            decoration: DottedDecoration(
                              color: Colors.white,
                              shape: Shape.line,
                              linePosition: LinePosition.right,
                              strokeWidth: 2.w,
                            ),
                          ),
                          Container(
                            width: vulnerablePhonemesSize.width,
                            height: 250.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0.w, vertical: 8.0.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Material(
                                  color: Color(0xFFF5F5F5),
                                  child: Text(
                                    'Vulnerable Phonemes',
                                    style: TextStyle(
                                      color: Color(0xFF282722),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 6.0.h),
                                  child: TextButton.icon(
                                    onPressed: null,
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFf5E5D58),
                                      backgroundColor: const Color(0xFFF2EBE3),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 5.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      surfaceTintColor: Colors.transparent,
                                    ),
                                    icon: const Icon(
                                      Icons.add,
                                      size: 24,
                                    ),
                                    label: const Text(
                                      'Add phonemes',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Material(
                                      color: const Color(0xFFF5F5F5),
                                      child: Column(
                                        children: List.generate(
                                            weakPhonemes.length, (index) {
                                          return VulnerableCardItem(
                                            index: index,
                                            phonemes: weakPhonemes[index]
                                                    ['phonemeText']
                                                .split(" ")
                                                .last,
                                            title: weakPhonemes[index]
                                                    ['phonemeText']
                                                .split(" ")
                                                .sublist(
                                                    0,
                                                    weakPhonemes[index]
                                                                ['phonemeText']
                                                            .split(" ")
                                                            .length -
                                                        1)
                                                .join(' '),
                                            phonemeId: weakPhonemes[index]
                                                ['phonemeId'],
                                            onDelete: () {},
                                          );
                                        }),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 2.0.h),
                                      child: Center(
                                        child: TextButton(
                                          onPressed: null,
                                          style: TextButton.styleFrom(
                                            backgroundColor: primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            fixedSize: const Size.fromWidth(
                                                double.maxFinite),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 3,
                                            ),
                                            child: Text(
                                              'Pronunciation Test',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
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
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink(); // 키가 없을 때 빈 위젯 반환
            },
          ),
        ],
      ),
    );
  }
}
