import 'package:flutter_application_1/new_learning_coures/unit_subtitle_class.dart';

/// Unit 정의
class Unit {
  final int id;
  final int totalNumber;
  int completedNumber;
  final String level;
  final String title;
  final String subtitle;

  Unit({
    required this.id,
    required this.totalNumber,
    required this.completedNumber,
    required this.level,
    required this.title,
    required this.subtitle,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    int id = json['id'];
    String level;
    String title;
    String subtitle;

    // level 설정
    if (id >= 1 && id <= 4) {
      level = "Beginner";
    } else if (id >= 5 && id <= 15) {
      level = "Intermediate";
    } else {
      level = "Advanced";
    }

    // title 설정
    if (id >= 1 && id <= 15) {
      title = "Unit $id";
    } else if (id >= 16 && id <= 22) {
      title = "Conversation Practice";
    } else {
      title = "Tongue Twisters";
    }

    // subtitle 설정
    if (id >= 5 && id <= 15) {
      subtitle = UnitSubtitle.getIntermediateSubtitle(id);
    } else {
      subtitle = UnitSubtitle.getSubtitle(id);
    }

    return Unit(
      id: id,
      totalNumber: json['totalNumber'],
      completedNumber: json['completedNumber'],
      level: level,
      title: title,
      subtitle: subtitle,
    );
  }
}
