/// 이미지 저장 경로
enum ImagePath {
  loginBgText(path: 'assets/image/login_bg_text.png'),
  loginBalbamCharacter(path: 'assets/image/login_balbam_character.svg'),
  recoverDialogBalbam(path: 'assets/image/recover_dialog_balbam.svg'),
  deleteDialogCryingBalbam(
      path: 'assets/image/delete_dialog_crying_balbam.svg'),
  notiCharacter(path: 'assets/image/noti_character.svg'),

  // 홈 화면 발밤 캐릭터
  balbamCharacter1(path: 'assets/image/home_character/balbam_1.svg'),
  balbamCharacter2(path: 'assets/image/home_character/balbam_2.svg'),
  balbamCharacter3(path: 'assets/image/home_character/balbam_3.svg'),
  balbamCharacter4(path: 'assets/image/home_character/balbam_4.svg'),
  balbamCharacter5(path: 'assets/image/home_character/balbam_5.svg'),

  // Feedback Dialog Stamp
  feedbackStamp1(path: 'assets/image/feedback_stamp/feedback_stamp_1.svg'),
  feedbackStamp2(path: 'assets/image/feedback_stamp/feedback_stamp_2.svg'),
  feedbackStamp3(path: 'assets/image/feedback_stamp/feedback_stamp_3.svg'),

  // Dialog 캐릭터
  welcomeDialog(path: 'assets/image/dialog_character/welcome.svg'),
  longTimeNoSeeDialog(path: 'assets/image/dialog_character/longTimeNoSee.svg'),
  attendance1Dialog(path: 'assets/image/dialog_character/attendance1.svg'),
  attendance2Dialog(path: 'assets/image/dialog_character/attendance2.svg'),
  recordingErrorDialog(
      path: 'assets/image/dialog_character/recording_error.svg');

  final String path;
  const ImagePath({required this.path});
}
