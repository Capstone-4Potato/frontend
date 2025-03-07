/// 이미지 저장 경로
enum ImagePath {
  loginBgText(path: 'assets/image/login_bg_text.png'),
  loginBalbamCharacter(path: 'assets/image/login_balbam_character.svg'),
  recoverDialogBalbam(path: 'assets/image/recover_dialog_balbam.svg'),
  deleteDialogCryingBalbam(
      path: 'assets/image/delete_dialog_crying_balbam.svg'),
  notiCharacter(path: 'assets/image/noti_character.svg'),
  balbamCharacter1(path: 'assets/image/balbam_character_1.svg'),
  welcome(path: 'assets/image/welcome.svg'),
  longTimeNoSee(path: 'assets/image/longTimeNoSee.svg'),
  attendance1(path: 'assets/image/attendance1.svg'),
  attendance2(path: 'assets/image/attendance2.svg');

  final String path;
  const ImagePath({required this.path});
}
