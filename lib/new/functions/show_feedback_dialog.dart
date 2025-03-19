// 피드백 다이얼로그 표시
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/new/widgets/dialogs/feedback_dialog.dart';

/// feedback Dialog 호출 함수
void showFeedbackDialog(BuildContext context, FeedbackData feedbackData,
    String recordedFilePath, String correctText) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return FeedbackDialog(
            feedbackData: feedbackData,
            recordedFilePath: recordedFilePath,
            correctText: correctText);
      });
}
