import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/new_report/report_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

/// 리포트 화면 튜토리얼 1
class ReportTutorialScreen1 extends StatelessWidget {
  const ReportTutorialScreen1({
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

    // 렌더링된 후 위치와 크기를 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // report 분석 아이템 카드 위치와 크기
      final RenderBox? reportAnalysisItemRenderBox =
          keys['reportAnalysisItemKey']?.currentContext?.findRenderObject()
              as RenderBox?;
      if (reportAnalysisItemRenderBox != null) {
        final reportAnalysisItemSize = reportAnalysisItemRenderBox.size;
        final reportAnalysisItemPosition =
            reportAnalysisItemRenderBox.localToGlobal(Offset.zero);
      }

      // 취약 음소 상자 위치와 크기
      final RenderBox? vulnerablePhonemesRenderBox =
          keys['vulnerablePhonemesKey']?.currentContext?.findRenderObject()
              as RenderBox?;
      if (vulnerablePhonemesRenderBox != null) {
        final vulnerablePhonemesSize = vulnerablePhonemesRenderBox.size;
        final vulnerablePhonemesPosition =
            vulnerablePhonemesRenderBox.localToGlobal(Offset.zero);
      }

      // homeNavigation bar 상자 위치와 크기
      final RenderBox? homeNavContainerRenderBox = keys['homeNavContainerKey']
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (homeNavContainerRenderBox != null) {
        final vulnerablePhonemesSize = homeNavContainerRenderBox.size;
        final vulnerablePhonemesPosition =
            homeNavContainerRenderBox.localToGlobal(Offset.zero);
      }

      // homeNavigation bar FAB 위치와 크기
      final RenderBox? homeNavFabRenderBox = keys['homeNavFabKey']
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (homeNavFabRenderBox != null) {
        final homeNavFabSize = homeNavFabRenderBox.size;
        final homeNavFabPosition =
            homeNavFabRenderBox.localToGlobal(Offset.zero);
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
              // report 분석 아이템 위치와 크기
              final RenderBox? reportAnalysisItemRenderBox =
                  keys['reportAnalysisItemKey']
                      ?.currentContext
                      ?.findRenderObject() as RenderBox?;
              // 취약음소 위치와 크기
              final RenderBox? vulnerablePhonemesRenderBox =
                  keys['vulnerablePhonemesKey']
                      ?.currentContext
                      ?.findRenderObject() as RenderBox?;
              // homeNav 상자 위치와 크기
              final RenderBox? homeNavContainerRenderBox =
                  keys['homeNavContainerKey']
                      ?.currentContext
                      ?.findRenderObject() as RenderBox?;
              // homeNav FAB 위치와 크기
              final RenderBox? homeNavFabRenderBox = keys['homeNavFabKey']
                  ?.currentContext
                  ?.findRenderObject() as RenderBox?;

              if (reportAnalysisItemRenderBox != null &&
                  vulnerablePhonemesRenderBox != null &&
                  homeNavContainerRenderBox != null &&
                  homeNavFabRenderBox != null) {
                // report 분석 아이템 위치와 크기
                final reportAnalysisItemSize = reportAnalysisItemRenderBox.size;
                final reportAnalysisItemPostion =
                    reportAnalysisItemRenderBox.localToGlobal(Offset.zero);
                // 취약음소 위치와 크기
                final vulnerablePhonemesSize = vulnerablePhonemesRenderBox.size;
                final vulnerablePhonemesPosition =
                    vulnerablePhonemesRenderBox.localToGlobal(Offset.zero);
                // homeNav 상자 위치와 크기
                final homeNavContainerSize = homeNavContainerRenderBox.size;
                final homeNavContainerPosition =
                    homeNavContainerRenderBox.localToGlobal(Offset.zero);
                // homeNav FAB 위치와 크기
                final homeNavFabSize = homeNavFabRenderBox.size;
                final homeNavFabPosition =
                    homeNavFabRenderBox.localToGlobal(Offset.zero);

                return Stack(
                  children: [
                    Positioned(
                      top: reportAnalysisItemPostion.dy + 10.h,
                      left: vulnerablePhonemesPosition.dx,
                      right: vulnerablePhonemesPosition.dx,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 460.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.0.w, vertical: 15.0.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Material(
                              child: SizedBox(
                                width: 368.w,
                                height: 460.h,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Wrap(
                                      spacing: 40.w,
                                      children: [
                                        AnalysisItem(
                                          icon: '🕰️',
                                          title: 'Study Days',
                                          value: 15,
                                          unit: 'days',
                                        ),
                                        AnalysisItem(
                                          icon: '📖',
                                          title: 'Learned',
                                          value: 21,
                                          unit: '',
                                        ),
                                        AnalysisItem(
                                          icon: '👍',
                                          title: 'Accuracy',
                                          value: 95,
                                          unit: '%',
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 26.0.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Weekly Average",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFFBEBDB8),
                                            ),
                                          ),
                                          const Text.rich(
                                            TextSpan(
                                              text: '18 ',
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: Color(0xFF5E5D58),
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: 'cards',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFFBEBDB8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: 12.0.h),
                                            child: AspectRatio(
                                              aspectRatio: 382 / 265,
                                              child: BarChart(
                                                weeklyData(60),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 0.11.w,
                            height: 40.h,
                            decoration: DottedDecoration(
                              color: Colors.white,
                              shape: Shape.line,
                              linePosition: LinePosition.left,
                              strokeWidth: 2.w,
                            ),
                          ),
                          Container(
                            width: 10.w,
                            height: 10.h,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.88),
                      child: SizedBox(
                        width: 300.w,
                        height: 150.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DefaultTextStyle(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.h,
                                  fontWeight: FontWeight.w500),
                              child: const Text(
                                'We show you useful insights\nfor your progress in this page.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: homeNavContainerPosition.dy,
                      left: homeNavContainerPosition.dx,
                      child: Container(
                        width: homeNavContainerSize.width.w,
                        height: homeNavContainerSize.height.h,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 242, 235, 227),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 45.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home,
                                    size: 24,
                                    color: bam,
                                  ),
                                  DefaultTextStyle(
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: bam,
                                        fontSize: 18.h,
                                        fontWeight: FontWeight.w500),
                                    child: const Text(
                                      'home',
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_2,
                                    size: 24,
                                    color: primary,
                                  ),
                                  DefaultTextStyle(
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: primary,
                                        fontSize: 18.h,
                                        fontWeight: FontWeight.w500),
                                    child: const Text(
                                      'Report',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: homeNavFabPosition.dy,
                      left: homeNavFabPosition.dx,
                      child: Container(
                        width: 98.w,
                        height: 98.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF26647),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.4),
                              width: 4.0.w),
                        ),
                        child: const Icon(
                          Icons.menu_book_outlined,
                          size: 44,
                          color: Colors.white,
                        ),
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
                const TextSpan(
                  text: ' cards',
                  style: TextStyle(
                    color: Color(0xFF92918C), //widget.touchedBarColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 30,
            interval: 1,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (maxCardValue / 5).toDouble(),
            getTitlesWidget: (value, meta) {
              return Container(
                padding: const EdgeInsets.only(left: 10),
                child: Text(value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFFBEBDB8),
                      fontSize: 15,
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
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Color(0xFFD8D7D6),
          strokeWidth: 1,
          dashArray: [1, 1],
        ),
        verticalInterval: 1 / 7,
        getDrawingVerticalLine: (value) => const FlLine(
          color: Color(0xFFD8D7D6),
          strokeWidth: 1,
          dashArray: [1, 1],
        ),
      ),
      extraLinesData: ExtraLinesData(
        extraLinesOnTop: false,
        horizontalLines: [
          HorizontalLine(
            y: 18,
            color: const Color(0xFFF26647),
            strokeWidth: 1.0,
          )
        ],
      ),
    );
  }

  /// 가로 축 title 정의
  Widget getTitles(double value, TitleMeta meta) {
    // x 축 text style
    const style = TextStyle(
      color: Color(0xFF5E5D58),
      fontWeight: FontWeight.w400,
      fontSize: 12,
    );
    List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];

    Widget text = Text(
      days[value.toInt()],
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10, // 축과 text 간 공간

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
              ? x == 5
                  ? const Color(0xFFF26647) // 튜토라서 금요일만 주황색
                  : const Color(0xFFF9C6A9)
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
          ),
          width: 29.w,
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 0, isTouched: false);
          case 1:
            return makeGroupData(1, 3, isTouched: false);
          case 2:
            return makeGroupData(2, 38, isTouched: false);
          case 3:
            return makeGroupData(3, 13, isTouched: true);
          case 4:
            return makeGroupData(4, 25, isTouched: false);
          case 5:
            return makeGroupData(5, 48, isTouched: false);
          case 6:
            return makeGroupData(6, 0, isTouched: false);

          default:
            return throw Error();
        }
      });
}
