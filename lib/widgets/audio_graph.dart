import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
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
      height: 230.h, // 그래프의 높이
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
              spots: _normalizeDataSpots(
                  correctAudioData, maxX), // 올바른 오디오 데이터의 점들
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
              spots:
                  _normalizeDataSpots(userAudioData, maxX), // 사용자 오디오 데이터의 점들
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

  // 데이터를 정규화하고 시간축을 조정하는 메서드
  List<FlSpot> _normalizeDataSpots(
      List<AmplitudeData> data, double targetDuration) {
    if (data.isEmpty) {
      // 데이터가 없는 경우 빈 배열 대신 시작점과 끝점을 포함하는 플랫 라인 반환
      return [
        const FlSpot(0, 0), // 시작점
        FlSpot(targetDuration, 0), // 끝점
      ];
    }

    // 첫 번째 시간값을 0으로 맞추기 위해 오프셋 계산
    double timeOffset = data.first.time;

    // 데이터의 실제 지속 시간 계산
    double originalDuration = data.last.time - timeOffset;

    // 시간축 스케일 팩터 계산
    double scaleFactor = targetDuration / originalDuration;

    // 데이터 포인트 정규화 및 변환
    return data.map((point) {
      // 시간값에서 오프셋을 빼고 스케일 팩터를 적용
      double normalizedTime = (point.time - timeOffset) * scaleFactor;
      return FlSpot(normalizedTime, point.amplitude);
    }).toList();
  }

  // 두 데이터 세트 중 최대 지속시간을 반환하는 메서드
  double _getMaxDuration(
      List<AmplitudeData> correctData, List<AmplitudeData> userData) {
    // 각 데이터 세트의 실제 지속 시간 계산
    double correctDuration = correctData.isNotEmpty
        ? correctData.last.time - correctData.first.time
        : 0.0;
    double userDuration =
        userData.isNotEmpty ? userData.last.time - userData.first.time : 0.0;

    return max(correctDuration, userDuration);
  }
}
