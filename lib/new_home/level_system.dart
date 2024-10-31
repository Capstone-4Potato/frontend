class LevelSystem {
  final Map<String, int> levelExperienceMap = {};

  LevelSystem() {
    _initializeLevels();
  }

  void _initializeLevels() {
    // 레벨 1~5 초기화
    levelExperienceMap["Level 1"] = 10;
    levelExperienceMap["Level 2"] = 20;
    levelExperienceMap["Level 3"] = 30;
    levelExperienceMap["Level 4"] = 40;
    levelExperienceMap["Level 5"] = 50; // 초급 끝
    for (int i = 1; i <= 5; i++) {
      levelExperienceMap["level $i"] = i * 10;
    }

    // 레벨 6~10 초기화
    levelExperienceMap["Level 6"] = 100;
    levelExperienceMap["Level 7"] = 200;
    levelExperienceMap["Level 8"] = 300;
    levelExperienceMap["Level 9"] = 400;
    levelExperienceMap["Level 10"] = 450; // 중급 끝

    // 레벨 11부터 50까지 50씩 증가하여 반복 패턴 적용
    for (int i = 11; i <= 50; i++) {
      levelExperienceMap["level $i"] = 500 + (i - 11) * 50;
    }
  }

  int getExperienceForLevel(String level) {
    return levelExperienceMap[level] ?? 0; // 레벨이 없으면 0 반환
  }
}
