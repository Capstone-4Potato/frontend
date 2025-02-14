import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_application_1/new/models/colors.dart';
import 'package:flutter_application_1/new/models/font_family.dart';
import 'package:flutter_application_1/new/widgets/sign_in_image_button.dart';
import 'package:flutter_application_1/new/models/login_platform.dart';

/// 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Flexible(
              flex: 6,
              child: Center(
                child: Image.asset('assets/image/title_logo.png'),
              ),
            ),
            const Spacer(flex: 5),
            Text(
              'Log in or sign up to Get Started !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bam.withValues(alpha: 0.7),
                fontFamily: FontFamily.bmJua.fontName,
                fontSize: 18.0.h,
                fontWeight: FontWeight.w400,
                wordSpacing: 1.1.w,
              ),
            ),
            SizedBox(height: 10.h),
            ...[
              LoginPlatform.apple,
              LoginPlatform.kakao,
              LoginPlatform.google,
            ]
                .map((platform) => SignInImageButton(loginPlatform: platform))
                .toList(),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
