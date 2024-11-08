import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/login/login_platform.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_home/home_cards.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
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

  List<Map<String, dynamic>>? weakPhonemes = [];

  bool isLoading = true; // 로딩 중 표시

  int touchedIndex = -1; // 그래프 터치 index

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchReportData() async {
    try {
      String? token = await getAccessToken();

      var url = Uri.parse('$main_url/report');

      // Set headers with the token
      var headers = <String, String>{
        'access': '$token',
        'Content-Type': 'application/json',
      };

      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (mounted) {
          setState(() {
            nickname = data['nickname'];
            studyDays = data['studyDays'];
            totalLearned = data['totalLearned'];
            accuracy =
                data['accuracy'] != null ? data['accuracy'].toDouble() : 0.0;
            weeklyAverageCards = data['weeklyAverageCards'];
            sundayCards = data['sundayCards'];
            mondayCards = data['mondayCards'];
            tuesdayCards = data['tuesdayCards'];
            wednesdayCards = data['wednesdayCards'];
            thursdayCards = data['thursdayCards'];
            fridayCards = data['fridayCards'];
            saturdayCards = data['saturdayCards'];

            // weakPhonemes 리스트 처리
            weakPhonemes = (data['weakPhonemes'] ?? [])
                .map<Map<String, dynamic>>((phoneme) => {
                      'rank': phoneme['rank'],
                      'phonemeId': phoneme['phonemeId'],
                      'phonemeText': phoneme['phonemeText'],
                    })
                .toList();

            isLoading = false; // 로딩 중 상태 변환
          });
        }
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

                // weakPhonemes 리스트 처리
                weakPhonemes = (data['weakPhonemes'] ?? [])
                    .map<Map<String, dynamic>>((phoneme) => {
                          'rank': phoneme['rank'],
                          'phonemeId': phoneme['phonemeId'],
                          'phonemeText': phoneme['phonemeText'],
                        })
                    .toList();

                isLoading = false; // 로딩 중 상태 변환
              });
            }
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
    double width = MediaQuery.of(context).size.width / 392;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        backgroundColor: background,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF26647)),
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25.0, right: 25.0, bottom: 50.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Hello,\n',
                            style: const TextStyle(fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                text: '$nickname 👋',
                                style: const TextStyle(
                                  fontSize: 24,
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
                            child: Image.asset(
                              'assets/image/bam_character.png',
                              width: 65 * width,
                              height: 65 * height,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Wrap(
                        spacing: 40,
                        children: [
                          AnalysisItem(
                            icon: '🕰️',
                            title: 'Study Days',
                            value: 15,
                            unit: 'min',
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 26.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              text: 'NN ',
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
                          Container(
                            height: 32 * height,
                          ),
                          SizedBox(
                            height: 237 * height,
                            width: 343 * width,
                            child: BarChart(
                              weeklyData(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomHomeCard(
                      contents: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Vulnerable Phonemes",
                            style: TextStyle(
                              color: bam,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // 수평 점선
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11.0),
                            child: SizedBox(
                              width: 343,
                              height: 1,
                              child: CustomPaint(
                                painter: DottedLineHorizontalPainter(),
                              ),
                            ),
                          ),
                          VulnerableCardItem(
                            index: 1,
                            phonemes: 'ㄱ',
                            title: 'Final consonant',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11.0),
                            child: SizedBox(
                              width: 343,
                              height: 1,
                              child: CustomPaint(
                                painter: DottedLineHorizontalPainter(),
                              ),
                            ),
                          ),
                          VulnerableCardItem(
                            index: 1,
                            phonemes: 'ㄱ',
                            title: 'Final consonant',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11.0),
                            child: SizedBox(
                              width: 343,
                              height: 1,
                              child: CustomPaint(
                                painter: DottedLineHorizontalPainter(),
                              ),
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 28.0,
                                  vertical: 3,
                                ),
                                child: Text(
                                  'Pronounciation Test',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      boxColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // 차트 그리기
  BarChartData weeklyData() {
    return BarChartData(
      maxY: 31.0,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFFF2EBE3),
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              'Card\n',
              TextStyle(color: primary),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY).toInt().toString(),
                  style: TextStyle(
                    color: bam, //widget.touchedBarColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
            reservedSize: 38,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 10,
            getTitlesWidget: rightTitles,
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
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(
        show: true,
        checkToShowHorizontalLine: (value) => value % 10 == 0,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Color(0xFFD8D7D6),
          strokeWidth: 1,
          dashArray: [1],
        ),
        checkToShowVerticalLine: (value) {
          if (value == 0) {
            return true;
          } else {
            return false;
          }
        },
        getDrawingVerticalLine: (value) => const FlLine(
          color: Color(0xFFD8D7D6),
          strokeWidth: 1,
          dashArray: [1],
        ),
      ),
    );
  }

  // y축 타이들
  Widget rightTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFFBEBDB8),
      fontWeight: FontWeight.w400,
      fontSize: 15,
    );
    String text;
    if (value == 0) {
      text = '${value.toInt()}';
    } else if (value == 10) {
      text = '${value.toInt()}';
    } else if (value == 20) {
      text = '${value.toInt()}';
    } else if (value == 30) {
      text = '${value.toInt()}';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Center(
        child: Text(
          text,
          style: style,
        ),
      ),
    );
  }

  // 가로 축 title 정의
  Widget getTitles(double value, TitleMeta meta) {
    // x 축 text style
    const style = TextStyle(
      color: Color(0xFF5E5D58),
      fontWeight: FontWeight.w400,
      fontSize: 12,
    );
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun'];

    Widget text = Text(
      days[value.toInt()],
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 12, // 축과 text 간 공간

      child: text,
    );
  }

  // 막대 스타일 지정
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
              ? y == 30
                  ? primary // 가장 큰 값이면 주황색
                  : const Color(0xFFF9C6A9)
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
          ),
          width: 29,
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 8, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 18, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 7, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 15, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 22, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 11.5, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 6.5, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });
}

class VulnerableCardItem extends StatelessWidget {
  VulnerableCardItem({
    super.key,
    required this.index,
    required this.phonemes,
    required this.title,
  });

  int index;
  String phonemes;
  String title;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    double width = MediaQuery.of(context).size.width / 392;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$index',
          style: const TextStyle(
            color: Color(0xFFEDCAA8),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          phonemes,
          style: TextStyle(
            color: bam,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Container(
          width: 195 * width,
          color: Colors.transparent,
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF5E5D58),
              fontSize: 15,
            ),
          ),
        ),
        Container(
          height: 27 * height,
          width: 27 * width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFDBB5),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'X',
            style: TextStyle(
              color: primary,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// Study time, Learned, Accuracy 등 수치 항목을 나타내는 위젯
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
  int value;
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
            style: const TextStyle(
              fontSize: 28,
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF5E5D58),
          ),
        ),
        Text.rich(
          TextSpan(
            text: '$value',
            style: const TextStyle(fontSize: 20),
            children: <TextSpan>[
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFBEBDB8),
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
      ..strokeWidth = 1
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
