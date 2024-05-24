String processRecommendation(Map<int, Map<String, String?>> recommendCard) {
  // 각 추천 카드에 따라 특정 메시지를 반환합니다.
  if (recommendCard.containsKey(-100)) {
    return '👍🏼 Excellent 👍🏼';
  } else if (recommendCard.containsKey(-1) || recommendCard.containsKey(-4)) {
    return '🥺 Try Again 🥺';
  } else {
    // 모든 키를 추출하여 학습 내용을 조합합니다.
    List<String> messages = [];
    recommendCard.forEach((key, value) {
      messages.add('${value['text']}');
    });
    // 조합된 메시지를 생성합니다.
    if (messages.isNotEmpty) {
      return "${messages.join(' ')} 연습해보세요";
    }
  }
  return '알 수 없는 추천 카드';
}

void main() {
  Map<int, Map<String, String?>> recommendCard1 = {
    -100: {'text': 'perfect', 'category': null, 'subcategory': null}
  };
  Map<int, Map<String, String?>> recommendCard2 = {
    -1: {'text': 'not word', 'category': null, 'subcategory': null}
  };
  Map<int, Map<String, String?>> recommendCard3 = {
    72: {'text': '초성ㅃ', 'category': '음절', 'subcategory': '자음ㅂㅍㅃ'},
    10: {'text': '중성ㅕ', 'category': '음절', 'subcategory': '이중모음1'},
    282: {'text': '종성ㄱ', 'category': '단어', 'subcategory': '받침ㄱ'}
  };
  print(processRecommendation(recommendCard1)); // 👍🏼 Excellent 👍🏼
  print(processRecommendation(recommendCard2)); // 🥺 Try Again 🥺
  print(processRecommendation(recommendCard3)); // 초성ㅃ 중성ㅕ 종성ㄱ 연습해보세요
}
