class UnitSubtitle {
  static final Map<int, String> _subtitles = {
    1: "Basic consonants/vowels",
    2: "Words without final consonant",
    3: "Simple Words with final consonant",
    4: "Advanced Words with final consonant",
    16: "Greetings and Introductions",
    17: "Shopping and Dining",
    18: "Travel and Directions",
    19: "Work and Business",
    20: "Health and Emergencies",
    21: "Current Events and News",
    22: "Abstract Concepts and Debates",
    23: "Warm up words",
    24: "Twist and Turn",
    25: "Master Twisters",
  };

  static String getSubtitle(int id) {
    return _subtitles[id] ?? "Default Subtitle"; // 기본값
  }

  static String getIntermediateSubtitle(int id) {
    return _subtitles[id] ??
        "Words commonly used in daily life #${id - 4}"; // 기본값
  }
}
