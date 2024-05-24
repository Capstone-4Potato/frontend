import 'dart:convert';
import 'dart:typed_data';

class FeedbackData {
  final int cardId;
  final String userAudioText;
  final List<int> mistakenIndexes;
  final int userScore;
  final Map<String, Map<String, dynamic>> recommendCard;
  final List<String> recommendCardId;
  final List<String> recommendCardText;
  final List<String> recommendCardCategory;
  final List<String> recommendCardSubcategory;
  final Uint8List userWaveformImage;
  final Uint8List correctWaveformImage;
  final double userAudioDuration;
  final double correctAudioDuration;

  FeedbackData({
    required this.cardId,
    required this.userAudioText,
    required this.mistakenIndexes,
    required this.userScore,
    required this.recommendCard,
    required this.recommendCardId,
    required this.recommendCardText,
    required this.recommendCardCategory,
    required this.recommendCardSubcategory,
    required this.userWaveformImage,
    required this.correctWaveformImage,
    required this.userAudioDuration,
    required this.correctAudioDuration,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    //JSON에서 recommendCard 데이터를 파싱
    Map<String, Map<String, dynamic>> recommendCard =
        Map<String, Map<String, dynamic>>.from(json['recommendCard']);

    // 추천 카드 아이디, 텍스트, 카테고리, 서브카테고리를 별도의 리스트로 생성
    List<String> recommendCardId = [];
    List<String> recommendCardText = [];
    List<String> recommendCardCategory = [];
    List<String> recommendCardSubcategory = [];

    // 각 추천 카드의 카테고리와 서브카테고리 정보를 리스트에 추가
    recommendCard.forEach((key, value) {
      recommendCardId.add(key);
      recommendCardText.add(value['text'] ?? '');
      recommendCardCategory.add(value['category'] ?? ''); // null인 경우 빈 문자열 처리
      recommendCardSubcategory
          .add(value['subcategory'] ?? ''); // null인 경우 빈 문자열 처리
    });

    return FeedbackData(
      cardId: json['cardId'],
      userAudioText: json['userAudio']['text'],
      mistakenIndexes: List<int>.from(json['userAudio']['mistakenIndexes']),
      userScore: json['userScore'],
      recommendCard: recommendCard,
      recommendCardId: recommendCardId,
      recommendCardText: recommendCardText,
      recommendCardCategory: recommendCardCategory,
      recommendCardSubcategory: recommendCardSubcategory,
      userWaveformImage: base64Decode(json['waveform']['userWaveform']),
      correctWaveformImage: base64Decode(json['waveform']['correctWaveform']),
      userAudioDuration: json['waveform']['userAudioDuration'],
      correctAudioDuration: json['waveform']['correctAudioDuration'],
    );
  }
}
