/// 카테고리별 음소 정리
class Phonemes {
  final String name; // 카테고리 이름 (예: Initial Consonant, Vowel)
  final List<String> elements; // 해당 카테고리의 원소들

  const Phonemes({
    required this.name,
    required this.elements,
  });
}

// 데이터 정의
const List<Phonemes> phonemes = [
  Phonemes(
    name: "Initial Consonant",
    elements: [
      "ㄱ",
      "ㄲ",
      "ㅋ",
      "ㄷ",
      "ㄸ",
      "ㅌ",
      "ㅂ",
      "ㅍ",
      "ㅃ",
      "ㅅ",
      "ㅆ",
      "ㅈ",
      "ㅊ",
      "ㅉ",
      "ㄴ",
      "ㄹ",
      "ㅁ",
      "ㅇ",
      "ㅎ"
    ],
  ),
  Phonemes(
    name: "Vowel",
    elements: [
      "ㅏ",
      "ㅓ",
      "ㅗ",
      "ㅜ",
      "ㅡ",
      "ㅣ",
      "ㅐ",
      "ㅔ",
      "ㅑ",
      "ㅕ",
      "ㅛ",
      "ㅠ",
      "ㅒ",
      "ㅖ",
      "ㅘ",
      "ㅙ",
      "ㅝ",
      "ㅞ",
      "ㅚ",
      "ㅟ",
      "ㅢ"
    ],
  ),
  Phonemes(
    name: "Final Consonant",
    elements: [
      "ㄱ",
      "ㄴ",
      "ㄷ",
      "ㄹ",
      "ㅁ",
      "ㅂ",
      "ㅇ",
    ],
  ),
];
