import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_application_1/new/widgets/sign_in_image_button.dart';
import 'package:flutter_application_1/new/models/login_platform.dart';
import 'package:flutter_svg/svg.dart';

/// 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Stack(
        children: [
          // 로그인 화면 배경 문구
          Positioned(
            left: 0,
            top: 320.h,
            child: Image.asset(
              ImagePath.loginBgText.path,
              width: width,
            ),
          ),

          //버튼 및 text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 126.h),
              _buildLogoContainer(),
              _buildText('Welcome to', AppColors.brown_001, 52.0.h, 1.2),
              _buildText('Balbam\nBalbam', AppColors.orange_000, 48.0.h, 1.0),
              SizedBox(height: 125.h),
              _buildText('Log in or sign up to Get Started',
                  AppColors.brown_001, 18.0.h),
              SizedBox(height: 16.h),
              _buildSignInButtons(),
            ],
          ),
        ],
      ),
    );
  }

  /// 로고 아이콘 박스 빌드
  Widget _buildLogoContainer() {
    return Container(
      width: 58.0.w,
      height: 58.0.h,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SvgPicture.asset(
        ImagePath.loginBalbamCharacter.path,
      ),
    );
  }

  /// 로그인 화면 중앙 text 빌드
  Widget _buildText(String text, Color color, double fontSize,
      [double? height]) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontFamily: FontFamily.bmJua.fontName,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: height,
      ),
    );
  }

  /// 로그인 버튼 빌드
  Widget _buildSignInButtons() {
    return Column(
      children: LoginPlatform.values
          .map((platform) => SignInImageButton(loginPlatform: platform))
          .toList(),
    );
  }
}
