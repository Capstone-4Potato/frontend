import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 그래프
class AudioGraphWidget extends StatelessWidget {
  final FeedbackData feedbackData; // 그래프에 사용할 FeedbackData 객체

  const AudioGraphWidget({super.key, required this.feedbackData});

  @override
  Widget build(BuildContext context) {
    // FeedbackData에서 제공된 데이터를 사용하여 그래프를 그림
    List<AmplitudeData> correctAudioData = feedbackData.correctAudio ?? [];
    List<AmplitudeData> userAudioData = feedbackData.userAudio ?? [];

    // 그래프의 최대 X값은 두 오디오 데이터의 최대 시간 값에 맞추어 설정
    double maxX = _getMaxDuration(correctAudioData, userAudioData);

    return SizedBox(
      height: 250.h, // 그래프의 높이
      width: 280.h, // 그래프의 너비
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide(
                  color: Colors.black,
                ),
                bottom: BorderSide(
                  color: Colors.black,
                ),
              )), // 테두리 없앰
          lineBarsData: [
            // Correct Audio Data 차트
            LineChartBarData(
              spots: _getDataSpots(correctAudioData, maxX), // 올바른 오디오 데이터의 점들
              isCurved: true,
              dotData: const FlDotData(show: false),
              color: primary.withOpacity(0.8),
              barWidth: 5.w,
              preventCurveOverShooting: true,
              preventCurveOvershootingThreshold: 1,

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.4),
                    primary.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            // User Audio Data 차트
            LineChartBarData(
              spots: _getDataSpots(userAudioData, maxX), // 사용자 오디오 데이터의 점들
              isCurved: true,
              dotData: const FlDotData(show: false),
              color: bam.withOpacity(0.7),
              barWidth: 5.w,
              preventCurveOverShooting: true,
              preventCurveOvershootingThreshold: 1,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    bam.withOpacity(0.2),
                    bam.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(
              sideTitles: SideTitles(reservedSize: 1.w, showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(reservedSize: 40.w, showTitles: false),
            ),
            topTitles: AxisTitles(
              axisNameSize: 1.h,
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 1.w,
              ),
            ),
          ),

          gridData: const FlGridData(show: false),
          maxY: 1.0, // 진폭 값은 최대 1.0
          minY: 0.0,
          maxX: maxX, // 최대 X값은 데이터에 맞추어 설정
          minX: 0.0, // X축의 최소값은 0
        ),
      ),
    );
  }

  // 데이터 포인트를 FlSpot 리스트로 변환하는 메서드
  List<FlSpot> _getDataSpots(List<AmplitudeData> data, double duration) {
    if (data.isEmpty) return []; // 데이터가 없으면 빈 리스트 반환

    // 데이터를 maxX에 맞게 리스케일링
    double scaleFactor =
        duration / (data.last.time); // duration에 맞게 scale factor 계산

    return data
        .map((point) =>
            FlSpot(point.time * scaleFactor, point.amplitude)) // 시간 값을 리스케일링
        .toList(); // AmplitudeData를 FlSpot으로 변환
  }

  // 두 데이터 세트 중 최대 지속시간을 반환하는 메서드
  double _getMaxDuration(
      List<AmplitudeData> correctData, List<AmplitudeData> userData) {
    double correctMax = correctData.isNotEmpty
        ? correctData.last.time
        : 0.0; // Correct Audio의 마지막 시간
    double userMax =
        userData.isNotEmpty ? userData.last.time : 0.0; // User Audio의 마지막 시간
    return max(correctMax, userMax); // 두 데이터의 최대 시간 값 반환
  }
}
