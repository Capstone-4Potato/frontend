import 'package:shared_preferences/shared_preferences.dart';

// 학습 카드 갯수, 튜토 관련 정보 초기화
Future<void> initiallizeTutoInfo(bool isLogout) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // 정보 초기화
  await prefs.setInt('learnedCardCount', 0);
  await prefs.setInt('totalCard', 10);
  await prefs.setBool('checkTodayCourse', false);
  await prefs.remove('cardIdList');

  // 계정 삭제일 경우만 튜토리얼 초기화
  if (!isLogout) {
    await prefs.setInt('homeTutorialStep', 1);
    await prefs.setInt('reportTutorialStep', 1);
    await prefs.setInt('learningCourseTutorialStep', 1);
    await prefs.setInt('feedbackTutorialStep', 1);
  }
}
