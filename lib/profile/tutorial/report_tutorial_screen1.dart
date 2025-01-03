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
class ReportTutorialScreen1 extends StatefulWidget {
  const ReportTutorialScreen1({
    super.key,
    required this.keys,
    required this.onTap,
  });

  final Map<String, GlobalKey> keys;
  final VoidCallback onTap;
  @override
  State<ReportTutorialScreen1> createState() => _ReportTutorialScreen1State();
}

class _ReportTutorialScreen1State extends State<ReportTutorialScreen1> {
  Offset? reportAnalysisItemPosition;
  Size? reportAnalysisItemSize;
  Offset? homeNavContainerPosition;
  Size? homeNavContainerSize;
  Offset? homeNavFabPosition;
  Size? homeNavFabSize;

  @override
  void initState() {
    super.initState();
    // 초기 측정 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateMeasurements();
      }
    });
  }

  @override
  void didUpdateWidget(ReportTutorialScreen1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯이 업데이트될 때마다 측정 시도
    if (mounted) {
      _updateMeasurements();
    }
  }

  void _updateMeasurements() {
    // 모든 RenderBox 측정 시도
    final RenderBox? reportAnalysisItemRenderBox =
        widget.keys['reportAnalysisItemKey']?.currentContext?.findRenderObject()
            as RenderBox?;
    final RenderBox? homeNavContainerRenderBox =
        widget.keys['homeNavContainerKey']?.currentContext?.findRenderObject()
            as RenderBox?;
    final RenderBox? homeNavFabRenderBox =
        widget.keys['homeNavFabKey']?.currentContext?.findRenderObject()
            as RenderBox?;

    // 모든 RenderBox가 있을 때만 상태 업데이트
    if (reportAnalysisItemRenderBox != null &&
        homeNavContainerRenderBox != null &&
        homeNavFabRenderBox != null) {
      setState(() {
        reportAnalysisItemSize = reportAnalysisItemRenderBox.size;
        reportAnalysisItemPosition =
            reportAnalysisItemRenderBox.localToGlobal(Offset.zero);
        homeNavContainerSize = homeNavContainerRenderBox.size;
        homeNavContainerPosition =
            homeNavContainerRenderBox.localToGlobal(Offset.zero);
        homeNavFabSize = homeNavFabRenderBox.size;
        homeNavFabPosition = homeNavFabRenderBox.localToGlobal(Offset.zero);
      });
    }
  }

  // onTap 콜백 추가
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          // 반투명 배경
          Container(
            color: Colors.black.withOpacity(0.6),
            width: width,
            height: height,
          ),
          if (reportAnalysisItemPosition != null &&
              homeNavContainerPosition != null &&
              homeNavFabPosition != null)
            Stack(
              children: [
                Positioned(
                  top: reportAnalysisItemPosition!.dy + 10.h,
                  left: 11.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: width - 22.w,
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
                                  padding: EdgeInsets.only(top: 8.0.h),
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
                                        padding: EdgeInsets.only(top: 12.0.h),
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
                  top: homeNavContainerPosition!.dy,
                  left: homeNavContainerPosition!.dx,
                  child: Container(
                    width: homeNavContainerSize!.width.w,
                    height: homeNavContainerSize!.height.h,
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
                  top: homeNavFabPosition!.dy,
                  left: homeNavFabPosition!.dx,
                  child: Container(
                    width: 98.w,
                    height: 98.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF26647),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.black.withOpacity(0.4), width: 4.0.w),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
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
