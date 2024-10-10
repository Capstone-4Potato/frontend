import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/colors.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // Json 데이터 저장
  AudioData? audioData;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String name = '실례합니다';

  // 파일 읽기
  Future<void> loadJsonFromFile() async {
    String jsonString = await rootBundle.loadString('assets/data/$name.json');
    Map<String, dynamic> decodedJson = json.decode(jsonString);

    setState(() {
      audioData = AudioData.fromJson(decodedJson);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadJsonFromFile();
  }

  // // Uint8List 데이터를 오디오로 재생하는 함수
  // Future<void> playAudio(Uint8List audioBytes) async {
  //   await _audioPlayer.play(BytesSource(audioBytes));
  // }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 화면이 사라질 때 오디오 플레이어 자원 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return audioData == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "<$name>",
                  style: const TextStyle(fontSize: 20),
                ),
                Center(
                  child: SizedBox(
                    height: 300,
                    width: 350,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getHuDataSpots(audioData!),
                            isCurved: true,
                            dotData: const FlDotData(show: false),
                            color: bam.withOpacity(0.7),
                            barWidth: 2,
                            preventCurveOverShooting: true,
                            preventCurveOvershootingThreshold: 1,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  bam.withOpacity(0.2),
                                  bam.withOpacity(0.2),
                                  // Color.fromARGB(55, 249, 149, 179),
                                  // Color.fromARGB(55, 248, 114, 154),
                                  // Color.fromARGB(55, 237, 87, 132),
                                  // Color.fromARGB(155, 237, 52, 108),
                                ],
                              ),
                            ),
                          ),
                          LineChartBarData(
                            spots: _getAiDataSpots(audioData!),
                            isCurved: true,
                            dotData: const FlDotData(show: false),
                            color: primary.withOpacity(0.8),
                            barWidth: 2,
                            preventCurveOverShooting: true,
                            preventCurveOvershootingThreshold: 1,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  primary.withOpacity(0.4),
                                  primary.withOpacity(0.4),
                                  // Color.fromARGB(55, 149, 232, 249),
                                  // Color.fromARGB(55, 114, 224, 248),
                                  // Color.fromARGB(55, 87, 227, 237),
                                  // Color.fromARGB(55, 52, 234, 237),
                                ],
                              ),
                            ),
                          ),
                        ],
                        titlesData: const FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles:
                                SideTitles(reservedSize: 40, showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            axisNameSize: 40,
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        maxY: 1.0,
                        minY: 0.0,
                        maxX: max(audioData!.aiDuration, audioData!.huDuration),
                        minX: 0.0,
                      ),

                      duration: const Duration(milliseconds: 150), // Optional
                      curve: Curves.linear, // Optional
                    ),
                  ),
                ),
                // ElevatedButton(
                //   onPressed: audioData!.huAudioBytes != null
                //       ? () => playAudio(audioData!.huAudioBytes)
                //       : null, // hu_audio 데이터를 이용하여 재생
                //   child: const Text('Play hu_audio'),
                // ),
              ],
            ),
          );
  }

  // x축에 시간 (Time) 값을 라벨로 표시하는 메서드
  Widget _buildTimeTitle(double value, TitleMeta meta) {
    return Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 12));
  }

  // hu_data의 각 DataPoint를 차트의 좌표로 변환하는 메서드
  List<FlSpot> _getHuDataSpots(AudioData data) {
    double longer = max(audioData!.aiDuration, audioData!.huDuration);
    double shorter = min(audioData!.aiDuration, audioData!.huDuration);
    double ratio = longer / shorter;
    List<FlSpot> huSpots = [const FlSpot(0, 0)];

    // huSpots.addAll(longer == audioData!.huDuration
    //     ? data.huData
    //         .map((point) => FlSpot(point.time, point.amplitude))
    //         .toList()
    //     : data.huData
    //         .map((point) => FlSpot(point.time * ratio, point.amplitude))
    //         .toList());
    // return huSpots;
    // 원본 좌표 변환
    // 원본 좌표 변환
    List<FlSpot> originalSpots = longer == audioData!.aiDuration
        ? data.aiData
            .map((point) => FlSpot(point.time, point.amplitude))
            .toList()
        : data.aiData
            .map((point) => FlSpot(point.time * ratio, point.amplitude))
            .toList();

    // RDP 알고리즘을 적용하여 좌표를 간소화
    double epsilon = 0.08; // 허용 오차 값 (값이 클수록 점의 수가 줄어듦)
    List<FlSpot> simplifiedAiSpots = rdpSimplify(originalSpots, epsilon);

    return simplifiedAiSpots;
  }

  // ai_data의 각 DataPoint를 차트의 좌표로 변환하는 메서드
  List<FlSpot> _getAiDataSpots(AudioData data) {
    double longer = max(audioData!.aiDuration, audioData!.huDuration);
    double shorter = min(audioData!.aiDuration, audioData!.huDuration);
    double ratio = longer / shorter;
    List<FlSpot> aiSpots = [const FlSpot(0, 0)];

    // aiSpots.addAll(longer == audioData!.aiDuration
    //     ? data.aiData
    //         .map((point) => FlSpot(point.time, point.amplitude))
    //         .toList()
    //     : data.aiData
    //         .map((point) => FlSpot(point.time * ratio, point.amplitude))
    //         .toList());
    // return aiSpots;
    // 원본 좌표 변환
    // 원본 좌표 변환
    List<FlSpot> originalSpots = longer == audioData!.huDuration
        ? data.huData
            .map((point) => FlSpot(point.time, point.amplitude))
            .toList()
        : data.huData
            .map((point) => FlSpot(point.time * ratio, point.amplitude))
            .toList();

    // RDP 알고리즘을 적용하여 좌표를 간소화
    double epsilon = 0.08; // 허용 오차 값 (값이 클수록 점의 수가 줄어듦)
    List<FlSpot> simplifiedHuSpots = rdpSimplify(originalSpots, epsilon);

    return simplifiedHuSpots;
  }

// RDP 알고리즘을 적용하여 좌표 리스트를 간소화하는 메서드
  List<FlSpot> rdpSimplify(List<FlSpot> points, double epsilon) {
    if (points.length < 3) return points;

    // 최댓값을 찾아내기 위한 초기 변수 설정
    double maxDistance = 0.0;
    int index = 0;

    // 첫 번째와 마지막 점을 기준으로 거리 계산
    for (int i = 1; i < points.length - 1; i++) {
      double distance =
          perpendicularDistance(points[i], points.first, points.last);
      if (distance > maxDistance) {
        index = i;
        maxDistance = distance;
      }
    }

    // 최대 거리가 epsilon보다 크면 점을 나누고 재귀적으로 처리
    if (maxDistance > epsilon) {
      List<FlSpot> leftSegment = points.sublist(0, index + 1);
      List<FlSpot> rightSegment = points.sublist(index, points.length);
      List<FlSpot> resultLeft = rdpSimplify(leftSegment, epsilon);
      List<FlSpot> resultRight = rdpSimplify(rightSegment, epsilon);

      return resultLeft.sublist(0, resultLeft.length - 1) + resultRight;
    } else {
      return [points.first, points.last];
    }
  }

// 두 점 사이의 수직 거리를 계산하는 메서드
  double perpendicularDistance(FlSpot point, FlSpot lineStart, FlSpot lineEnd) {
    double dx = lineEnd.x - lineStart.x;
    double dy = lineEnd.y - lineStart.y;

    // 두 점이 동일한 경우 수직 거리 계산
    if (dx == 0 && dy == 0) {
      return (point.x - lineStart.x).abs();
    }

    // y = mx + c 형태의 직선 방정식 계산
    double m = dy / dx;
    double c = lineStart.y - m * lineStart.x;

    // 점에서 직선까지의 수직 거리 공식 사용
    return (m * point.x - point.y + c).abs() / sqrt(m * m + 1);
  }
}

class AudioData {
  final List<DataPoint> huData;
  final List<DataPoint> aiData;
  final Uint8List huAudioBytes;
  final Uint8List aiAudioBytes;
  double huDuration;
  double aiDuration;

  // 생성자
  AudioData({
    required this.huData,
    required this.aiData,
    required this.huAudioBytes,
    required this.aiAudioBytes,
    required this.huDuration,
    required this.aiDuration,
  });

  // JSON 데이터를 파싱하여 AudioData 객체를 생성하는 팩토리 메서드
  factory AudioData.fromJson(Map<String, dynamic> json) {
    return AudioData(
      huData: (json['hu_data'] as List)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
      aiData: (json['ai_data'] as List)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
      huAudioBytes: base64Decode(json['hu_audio']),
      aiAudioBytes: base64Decode(json['ai_audio']),
      huDuration: (json['hu_data'] as List).last['Time (s)'],
      aiDuration: (json['ai_data'] as List).last['Time (s)'],
    );
  }
}

// Time과 Amplitude 데이터를 저장할 클래스
class DataPoint {
  final double time;
  final double amplitude;

  DataPoint({required this.time, required this.amplitude});

  // JSON 데이터로부터 DataPoint 객체를 생성하는 팩토리 메서드
  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      time: json['Time (s)'], // JSON의 "Time (s)" 필드를 사용
      amplitude: json['Amplitude'], // JSON의 "Amplitude" 필드를 사용
    );
  }
}
