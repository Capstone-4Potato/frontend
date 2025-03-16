/// 이미지 저장 경로
enum ImagePath {
  loginBgText(path: 'assets/image/login_bg_text.png'),
  loginBalbamCharacter(path: 'assets/image/login_balbam_character.svg'),
  recoverDialogBalbam(path: 'assets/image/recover_dialog_balbam.svg'),
  deleteDialogCryingBalbam(
      path: 'assets/image/delete_dialog_crying_balbam.svg'),
  notiCharacter(path: 'assets/image/noti_character.svg'),
  welcome(path: 'assets/image/welcome.svg'),
  longTimeNoSee(path: 'assets/image/longTimeNoSee.svg'),

  balbamCharacter1(path: 'assets/image/home_character/balbam_1.svg'),
  balbamCharacter2(path: 'assets/image/home_character/balbam_2.svg'),
  balbamCharacter3(path: 'assets/image/home_character/balbam_3.svg'),
  balbamCharacter4(path: 'assets/image/home_character/balbam_4.svg'),
  balbamCharacter5(path: 'assets/image/home_character/balbam_5.svg'),

  attendance1(path: 'assets/image/attendance1.svg'),
  attendance2(path: 'assets/image/attendance2.svg');

  final String path;
  const ImagePath({required this.path});
}
