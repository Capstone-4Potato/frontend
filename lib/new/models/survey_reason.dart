/// 설문 탈퇴 이유
enum SurveyReason {
  dontUse,
  notFunctional,
  hardToUse,
  lacksContent,
  wantNewSystem,
  other,
}

extension SurveyReasonExtension on SurveyReason {
  String get label {
    switch (this) {
      case SurveyReason.dontUse:
        return "I don’t use it";
      case SurveyReason.notFunctional:
        return "It's not functional enough";
      case SurveyReason.hardToUse:
        return "It's hard to use";
      case SurveyReason.lacksContent:
        return "This app lacks learning content";
      case SurveyReason.wantNewSystem:
        return "I want to make a new system";
      case SurveyReason.other:
        return "Other (input)";
    }
  }
}
