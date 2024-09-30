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
  String name = '쏘가리';

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
                            color: primary.withOpacity(0.8),
                            barWidth: 4,
                            preventCurveOverShooting: true,
                            preventCurveOvershootingThreshold: 5,
                          ),
                          LineChartBarData(
                            spots: _getAiDataSpots(audioData!),
                            isCurved: true,
                            dotData: const FlDotData(show: false),
                            color: bam.withOpacity(0.7),
                            barWidth: 4,
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

    huSpots.addAll(longer == audioData!.huDuration
        ? data.huData
            .map((point) => FlSpot(point.time, point.amplitude))
            .toList()
        : data.huData
            .map((point) => FlSpot(point.time * ratio, point.amplitude))
            .toList());
    return huSpots;
  }

  // ai_data의 각 DataPoint를 차트의 좌표로 변환하는 메서드
  List<FlSpot> _getAiDataSpots(AudioData data) {
    double longer = max(audioData!.aiDuration, audioData!.huDuration);
    double shorter = min(audioData!.aiDuration, audioData!.huDuration);
    double ratio = longer / shorter;
    List<FlSpot> aiSpots = [const FlSpot(0, 0)];

    aiSpots.addAll(longer == audioData!.aiDuration
        ? data.aiData
            .map((point) => FlSpot(point.time, point.amplitude))
            .toList()
        : data.aiData
            .map((point) => FlSpot(point.time * ratio, point.amplitude))
            .toList());
    return aiSpots;
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
