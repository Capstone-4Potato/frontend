import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// 홈화면 메인 발밤이 캐릭터
class HomeCharacter extends StatelessWidget {
  const HomeCharacter({
    super.key,
    required this.characterIndex,
  });

  final int characterIndex;

  @override
  Widget build(BuildContext context) {
    List imagePath = [
      ImagePath.balbamCharacter1.path,
      ImagePath.balbamCharacter2.path,
      ImagePath.balbamCharacter3.path,
      ImagePath.balbamCharacter4.path,
      ImagePath.balbamCharacter5.path,
    ];
    return SvgPicture.asset(
      imagePath[characterIndex],
      width: 130.w,
    );
  }
}
