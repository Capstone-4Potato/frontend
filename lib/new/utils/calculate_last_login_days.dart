import 'package:intl/intl.dart';

/// 마지막 접속일수 계산 함수
int calculateLastLoginDays(String? dateString) {
  if (dateString == null) {
    return 0;
  }

  // 입력받은 날짜를 DateTime 객체로 변환
  DateTime inputDate = DateFormat("yyyy-MM-dd").parse(dateString);

  // 현재 날짜 가져오기 (시간은 00:00:00으로 초기화)
  DateTime today = DateTime.now();
  today = DateTime(today.year, today.month, today.day);

  // 날짜 차이 계산
  int difference = today.difference(inputDate).inDays;
  return difference;
}
