import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/learninginfo/deletephonemes.dart';
import 'package:flutter_application_1/learninginfo/re_test_page.dart';
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

            // 데이터 출력 확인용
            print("Nickname: $nickname");
            print("Study Days: $studyDays");
            print("Total Learned: $totalLearned");
            print("Accuracy: $accuracy");
            print("Weekly Average Cards: $weeklyAverageCards");
            print("Sunday Cards: $sundayCards");
            print("Monday Cards: $mondayCards");
            print("Tuesday Cards: $tuesdayCards");
            print("Wednesday Cards: $wednesdayCards");
            print("Thursday Cards: $thursdayCards");
            print("Friday Cards: $fridayCards");
            print("Saturday Cards: $saturdayCards");
            print("Weak Phonemes: $weakPhonemes");

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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    double width = MediaQuery.of(context).size.width / 392;

    int maxCardValue = (getMaxCardValue().toDouble() ~/ 5) * 5 + 5;

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
                          Text.rich(
                            TextSpan(
                              text: '$weeklyAverageCards ',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF5E5D58),
                              ),
                              children: const <TextSpan>[
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
                            height: 12 * height,
                          ),
                          AspectRatio(
                            aspectRatio: 382 / 265,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              child: BarChart(
                                weeklyData(maxCardValue),
                              ),
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
                          Column(
                            children:
                                List.generate(weakPhonemes!.length, (index) {
                              return VulnerableCardItem(
                                index: index + 1,
                                phonemes: weakPhonemes![index]['phonemeText']
                                    .split(' ')
                                    .last,
                                title: weakPhonemes![index]['phonemeText']
                                    .split(' ')
                                    .sublist(
                                        0,
                                        weakPhonemes![index]['phonemeText']
                                                .split(' ')
                                                .length -
                                            1)
                                    .join(' '),
                                phonemeId: weakPhonemes![index]['phonemeId'],
                                onDelete: () {
                                  setState(() {
                                    weakPhonemes!
                                        .removeAt(index); // 리스트에서 항목 삭제
                                  });
                                },
                              );
                            }),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext builder) =>
                                        const restartTestScreen(),
                                  ),
                                );
                              },
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
        horizontalInterval: (maxCardValue / 3).toDouble(),
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
        horizontalLines: [
          HorizontalLine(
            y: weeklyAverageCards!.toDouble(),
            color: weeklyAverageCards!.toDouble() == 0
                ? Colors.transparent
                : const Color(0xFFF26647),
            strokeWidth: 1.0,
          )
        ],
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

  // 막대 스타일 지정
  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    List<int> showTooltips = const [],
  }) {
    double height = MediaQuery.of(context).size.height / 852;
    double width = MediaQuery.of(context).size.width / 392;

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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
          ),
          width: 29 * width,
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

  // 취약음소 삭제 API
  Future<void> deletePhonemes(int phonemeId) async {
    String? token = await getAccessToken();
    var url = Uri.parse('$main_url/test/phonemes/$phonemeId');

    // Function to make the delete request
    Future<http.Response> makeDeleteRequest(String token) {
      return http.delete(
        url,
        headers: <String, String>{
          'access': token,
          'Content-Type': 'application/json',
        },
      );
    }

    try {
      var response = await makeDeleteRequest(token!);

      if (response.statusCode == 200) {
        onDelete(); // 성공 시 콜백 호출
        print(response.body);
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh the token
        print('Access token expired. Refreshing token...');

        // Refresh the access token
        bool isRefreshed = await refreshAccessToken();
        if (isRefreshed) {
          // Retry the delete request with the new token
          token = await getAccessToken();
          response = await makeDeleteRequest(token!);

          if (response.statusCode == 200) {
            onDelete(); // 성공 시 콜백 호출
            print(response.body);
          } else {
            throw Exception('Failed to delete account after refreshing token');
          }
        } else {
          throw Exception('Failed to refresh access token');
        }
      } else {
        throw Exception('Failed to delete phoneme');
      }
    } catch (e) {
      // Handle errors that occur during the request
      print("Error deleting phoneme: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    double width = MediaQuery.of(context).size.width / 392;

    return Column(
      children: [
        Row(
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
            GestureDetector(
              onTap: () async {
                await deletePhonemes(phonemeId);
              },
              child: Container(
                height: 27 * height,
                width: 27 * width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.cancel,
                  color: Color(0xFFFFDBB5),
                  size: 27,
                ),
              ),
            ),
          ],
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5E5D58),
            ),
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
