import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_application_1/test_screen.dart';

/// 그래프 그리기 위한 엠플리튜드 데어터
class AmplitudeData {
  final double time;
  final double amplitude;

  AmplitudeData({required this.time, required this.amplitude});

  // JSON 데이터를 AmplitudeData 객체로 변환
  factory AmplitudeData.fromJson(Map<String, dynamic> json) {
    return AmplitudeData(
      time: json['Time (s)'] ?? 0.0,
      amplitude: json['Amplitude'] ?? 0.0,
    );
  }
}

class AudioData {
  final List<AmplitudeData> amplitudeList;

  AudioData({required this.amplitudeList});

  // JSON 데이터를 AudioData 객체로 변환
  factory AudioData.fromJson(Map<String, dynamic> json) {
    var list = json['amplitude'] as List;
    List<AmplitudeData> amplitudeList =
        list.map((e) => AmplitudeData.fromJson(e)).toList();

    return AudioData(amplitudeList: amplitudeList);
  }
}

/// 피드백 데이터
class FeedbackData {
  final int cardId;
  final List<int> mistakenIndexes;
  final int userScore;
  final Map<String, Map<String, dynamic>> recommendCard;
  final List<String> recommendCardId;
  final List<String> recommendCardText;
  final List<String> recommendCardCategory;
  final List<String> recommendCardSubcategory;
  final List<AmplitudeData>? correctAudio;
  final List<AmplitudeData>? userAudio;

  FeedbackData({
    required this.cardId,
    required this.mistakenIndexes,
    required this.userScore,
    required this.recommendCard,
    required this.recommendCardId,
    required this.recommendCardText,
    required this.recommendCardCategory,
    required this.recommendCardSubcategory,
    required this.correctAudio,
    required this.userAudio,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    // recommendCard 처리
    Map<String, Map<String, dynamic>> recommendCard = {};
    List<String> recommendCardId = [];
    List<String> recommendCardText = [];
    List<String> recommendCardCategory = [];
    List<String> recommendCardSubcategory = [];
    List<AmplitudeData>? correctAudio = [];

    if (json['recommendCard'] != null && json['recommendCard'] is Map) {
      recommendCard =
          Map<String, Map<String, dynamic>>.from(json['recommendCard']);

      recommendCard.forEach((key, value) {
        recommendCardId.add(key);
        recommendCardText.add(value['text'] ?? '');
        recommendCardCategory.add(value['category'] ?? '');
        recommendCardSubcategory.add(value['subcategory'] ?? '');
      });
    }

    var correctAudioList = (json['correctAudio']['amplitude'] as List)
        .map((e) => AmplitudeData.fromJson(e))
        .toList();
    var userAudioList = (json['userAudio']['amplitude'] as List)
        .map((e) => AmplitudeData.fromJson(e))
        .toList();

    return FeedbackData(
      cardId: json['cardId'] ?? 0,
      mistakenIndexes: json['mistakenIndexes'] != null
          ? List<int>.from(json['mistakenIndexes'])
          : [],
      userScore: json['userScore'] ?? 0,
      recommendCard: recommendCard,
      recommendCardId: recommendCardId,
      recommendCardText: recommendCardText,
      recommendCardCategory: recommendCardCategory,
      recommendCardSubcategory: recommendCardSubcategory,
      correctAudio: correctAudioList,
      userAudio: userAudioList,
    );
  }

  // recommendCard의 key를 반환하는 메서드  ("perfect", "try again")
  String getRecommendCardKey() {
    return recommendCard.keys.isNotEmpty ? recommendCard.keys.first : '';
  }
}
