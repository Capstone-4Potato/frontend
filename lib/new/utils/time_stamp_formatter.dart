import 'package:intl/intl.dart';

/// 생성 날짜 받아서 `YYYY.MM.DD` 포맷 지정
String formatTimeStamp(String createdAt) {
  final now = DateTime.now();
  final notificationTime = DateTime.parse(createdAt);

  if (now.difference(notificationTime).inDays == 0) {
    // The notification was created today
    final difference = now.difference(notificationTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return '${difference.inHours} hours ago';
    }
  } else {
    // The notification was created on a different day
    return DateFormat('yyyy.MM.dd').format(notificationTime);
  }
}
