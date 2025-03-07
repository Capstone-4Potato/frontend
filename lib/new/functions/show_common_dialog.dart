// recording error 타입 Enum으로 정의
import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_application_1/new/widgets/dialogs/common_dialog.dart';

enum DialogType { welcome, attendance1, attendance2, longTimeNoSee }

void showCommonDialog(BuildContext context,
    {DialogType type = DialogType.attendance1}) {
  String imagePath;
  String title;
  String content;

  switch (type) {
    case DialogType.welcome:
      imagePath = ImagePath.welcome.path;
      title = "Welcome!";
      content = "Welcome to Balbam Balmbam.\nYour Korean journey starts NOW!";
      break;
    case DialogType.attendance1:
      imagePath = ImagePath.attendance1.path;
      title = "Good Job!";
      content = "🎉 You're back! 🌟\nYour Korean skills are leveling up! 🔥💪";
      break;
    case DialogType.attendance2:
      imagePath = ImagePath.attendance2.path;
      title = "Great Job!";
      content = "🎉 You're back! 🌟\nYour Korean skills are leveling up! 🔥💪";
      break;
    case DialogType.longTimeNoSee:
      imagePath = ImagePath.longTimeNoSee.path;
      title = "Oh No..";
      content = "You haven't come in for a long time.\nLet’s start over !";
      break;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CommonDialog(
        imagePath: imagePath,
        title: title,
        content: content,
      );
    },
  );
}
