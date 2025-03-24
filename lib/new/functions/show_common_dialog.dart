import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_application_1/new/widgets/dialogs/common_dialog.dart';

/// dialog 타입 정의
enum DialogType {
  welcome,
  attendance1,
  attendance2,
  longTimeNoSee,
  recordingError
}

// recording error 타입 Enum으로 정의
enum RecordingErrorType { generic, timeout, tooShort }

void showCommonDialog(
  BuildContext context, {
  DialogType dialogType = DialogType.attendance1,
  String? customTitle,
  String? customContent,
  String? customButtonText,
  RecordingErrorType recordingErrorType = RecordingErrorType.generic,
}) {
  String imagePath;
  String title;
  String content;
  String buttonText = "Go ahead";

  // First set default values based on type
  switch (dialogType) {
    case DialogType.welcome:
      imagePath = ImagePath.welcomeDialog.path;
      title = "Welcome!";
      content = "Welcome to Balbam Balmbam.\nYour Korean journey starts NOW!";
      break;
    case DialogType.attendance1:
      imagePath = ImagePath.attendance1Dialog.path;
      title = "Good Job!";
      content = "🎉 You're back! 🌟\nYour Korean skills are leveling up! 🔥💪";
      break;
    case DialogType.attendance2:
      imagePath = ImagePath.attendance2Dialog.path;
      title = "Great Job!";
      content = "🎉 You're back! 🌟\nYour Korean skills are leveling up! 🔥💪";
      break;
    case DialogType.longTimeNoSee:
      imagePath = ImagePath.longTimeNoSeeDialog.path;
      title = "Oh No..";
      content = "You haven't come in for a long time.\nLet's start over !";
      break;
    case DialogType.recordingError:
      imagePath = ImagePath.recordingErrorDialog.path;
      title = "Recording Error";

      // Handle different recording error types
      switch (recordingErrorType) {
        case RecordingErrorType.timeout:
          content = "The server response timed out. Please try again.";
          break;
        case RecordingErrorType.tooShort:
          content = "Please press the stop recording button a bit later.";
          break;
        case RecordingErrorType.generic:
          content = "Please try recording again.";
      }

      buttonText = "Continue";
      break;
  }

  // Override with custom values if provided
  if (customTitle != null) {
    title = customTitle;
  }
  if (customContent != null) {
    content = customContent;
  }
  if (customButtonText != null) {
    buttonText = customButtonText;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CommonDialog(
        imagePath: imagePath,
        title: title,
        content: content,
        buttonText: buttonText,
        onPressed: () {
          Navigator.pop(context);
        },
      );
    },
  );
}
