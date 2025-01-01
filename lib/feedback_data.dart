import 'dart:convert';
import 'dart:typed_data';

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
  String userAudioText;
  String userText;
  String correctAudioText;
  final List<int> mistakenIndexes;
  final int userScore;
  final Map<String, Map<String, dynamic>> recommendCard;
  final List<String> recommendCardKey;
  final List<String> recommendCardText;
  final List<int> recommendCardId;
  final List<String> recommendCardCorrectAudio;
  final List<String> recommendCardTranslation;
  final List<String> recommendCardPronunciation;
  final List<String> recommendCardPictureUrl;
  final List<String> recommendCardExplanation;
  final List<bool> recommendCardBookmark;
  final List<bool> recommendCardWeakCard;

  final List<AmplitudeData>? correctAudio;
  final List<AmplitudeData>? userAudio;

  FeedbackData({
    required this.cardId,
    required this.userAudioText,
    required this.userText,
    required this.mistakenIndexes,
    required this.userScore,
    required this.recommendCard,
    required this.recommendCardKey,
    required this.recommendCardText,
    required this.recommendCardId,
    required this.recommendCardCorrectAudio,
    required this.recommendCardTranslation,
    required this.recommendCardPronunciation,
    required this.recommendCardPictureUrl,
    required this.recommendCardExplanation,
    required this.recommendCardBookmark,
    required this.recommendCardWeakCard,
    required this.correctAudio,
    required this.userAudio,
    required this.correctAudioText,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    // recommendCard 처리
    Map<String, Map<String, dynamic>> recommendCard = {};
    List<String> recommendCardKey = [];
    List<int> recommendCardId = [];
    List<String> recommendCardText = [];
    List<String> recommendCardCorrectAudio = [];
    List<String> recommendCardTranslation = [];
    List<String> recommendCardPronunciation = [];
    List<String> recommendCardPictureUrl = [];
    List<String> recommendCardExplanation = [];
    List<bool> recommendCardBookmark = [];
    List<bool> recommendCardWeakCard = [];

    if (json['recommendCard'] != null && json['recommendCard'] is Map) {
      recommendCard =
          Map<String, Map<String, dynamic>>.from(json['recommendCard']);

      recommendCard.forEach((key, value) {
        recommendCardKey.add(key);
        recommendCardId.add(value['id'] ?? 0);
        recommendCardText.add(value['text'] ?? '');
        recommendCardCorrectAudio.add(value['correctAudio'] ?? '');
        recommendCardTranslation.add(value['cardTranslation'] ?? '');
        recommendCardPronunciation.add(value['cardPronunciation'] ?? '');
        recommendCardPictureUrl.add(value['pictureUrl'] ?? '');
        recommendCardExplanation.add(value['explanation'] ?? '');
        recommendCardBookmark.add(value['bookmark'] ?? '');
        recommendCardWeakCard.add(value['weakCard'] ?? '');
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
      recommendCardKey: recommendCardKey,
      recommendCardId: recommendCardId,
      recommendCardText: recommendCardText,
      recommendCardCorrectAudio: recommendCardCorrectAudio,
      recommendCardTranslation: recommendCardTranslation,
      recommendCardPronunciation: recommendCardPronunciation,
      recommendCardPictureUrl: recommendCardPictureUrl,
      recommendCardExplanation: recommendCardExplanation,
      recommendCardBookmark: recommendCardBookmark,
      recommendCardWeakCard: recommendCardWeakCard,
      correctAudio: correctAudioList,
      userAudio: userAudioList,
      userAudioText: json['userAudio']['text'],
      userText: json['userText'],
      correctAudioText: json['correctAudio']['text'],
    );
  }

  // recommendCard의 key를 반환하는 메서드  ("perfect", "try again")
  String getRecommendCardKey() {
    return recommendCard.keys.isNotEmpty ? recommendCard.keys.first : '';
  }
}
