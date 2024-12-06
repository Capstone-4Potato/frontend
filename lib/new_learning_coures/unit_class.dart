import 'package:flutter_application_1/new_learning_coures/unit_subtitle_class.dart';

class Unit {
  final int id;
  final int totalNumber;
  final int completedNumber;
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
    } else if (id >= 5 && id <= 11) {
      level = "Intermediate";
    } else {
      level = "Advanced";
    }

    // title 설정
    if (id >= 1 && id <= 11) {
      title = "Unit $id";
    } else if (id >= 12 && id <= 18) {
      title = "Conversation Practice";
    } else {
      title = "Tongue Twisters";
    }

    // subtitle 설정
    if (id >= 5 && id <= 11) {
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
