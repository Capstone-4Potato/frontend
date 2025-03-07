import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/widgets/dialogs/recording_error_dialog.dart';

// recording error 타입 Enum으로 정의
enum RecordingErrorType { generic, timeout, tooShort }

void showRecordingErrorDialog(BuildContext context,
    {RecordingErrorType type = RecordingErrorType.generic}) {
  String errorMessage;

  switch (type) {
    case RecordingErrorType.timeout:
      errorMessage = "The server response timed out. Please try again.";
      break;
    case RecordingErrorType.tooShort:
      errorMessage = "Please press the stop recording button a bit later.";
      break;
    default:
      errorMessage = "Please try recording again.";
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return RecordingErrorDialog(text: errorMessage);
    },
  );
}
