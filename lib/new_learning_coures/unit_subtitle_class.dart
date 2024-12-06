class UnitSubtitle {
  static final Map<int, String> _subtitles = {
    1: "Basic consonants/vowels",
    2: "Words without final consonant",
    3: "Simple Words with final consonant",
    4: "Advanced Words with final consonant",
    12: "Greetings and Introductions",
    13: "Shopping and Dining",
    14: "Travel and Directions",
    15: "Work and Business",
    16: "Health and Emergencies",
    17: "Current Events and News",
    18: "Abstract Concepts and Debates",
    19: "Warm up words",
    20: "Twist and Turn",
    21: "Master Twisters",
  };

  static String getSubtitle(int id) {
    return _subtitles[id] ?? "Default Subtitle"; // 기본값
  }

  static String getIntermediateSubtitle(int id) {
    return _subtitles[id] ??
        "Words commonly used in daily life #${id - 4}"; // 기본값
  }
}
