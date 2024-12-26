import 'package:convert/convert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/custom_icons.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new_home/home_nav.dart';
import 'package:flutter_application_1/profile/logout/sign_out_social.dart';
import 'package:flutter_application_1/signup/signup_screen.dart';
import 'package:flutter_application_1/login/login_platform.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginPlatform _loginPlatform = LoginPlatform.none;

  @override
  void initState() {
    super.initState();
    _loadLoginPlatform();
  }

  Future<void> _loadLoginPlatform() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginPlatform = LoginPlatform.values[prefs.getInt('loginPlatform') ?? 4];
    });
  }

  Future<void> _saveLoginPlatform(LoginPlatform platform) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loginPlatform', platform.index);
  }

  // 소셜로그인 API
  Future<int> socialLogin(String? socialId) async {
    var url = Uri.parse('$main_url/login');

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['socialId'] = socialId!;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Assuming 'access' is the key for the access token in headers
        String? accessToken = response.headers['access'];
        String? refreshToken = response.headers['refresh'];

        if (accessToken != null && refreshToken != null) {
          await saveTokens(accessToken, refreshToken);
        }
      }

      return response.statusCode; // Return the status code
    } catch (e) {
      print('Network error occurred: $e');
      return 500; // Assume server error on exception
    }
  }

  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );

      int statusCode = await socialLogin(credential.userIdentifier);

      if (statusCode == 200 || statusCode == 404) {
        setState(() {
          _loginPlatform = LoginPlatform.apple;
        });
        await _saveLoginPlatform(LoginPlatform.apple);
      }
      return {
        'statusCode': statusCode,
        'socialId': credential.userIdentifier,
      };
    } catch (error) {
      print('error = $error');
      return {
        'statusCode': 500,
        'socialId': '',
      };
    }
  }

  Future<Map<String, dynamic>> signInWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        User user = await UserApi.instance.me();
        print('사용자 정보 요청 성공'
            '\n회원번호: ${user.id}');

        // 소셜 로그인 정보 전달
        int statusCode = await socialLogin(user.id.toString());
        if (statusCode == 200 || statusCode == 404) {
          setState(() {
            _loginPlatform = LoginPlatform.kakao;
          });
          await _saveLoginPlatform(LoginPlatform.kakao);
        }
        return {
          'statusCode': statusCode,
          'socialId': user.id.toString(),
        };
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        if (error is PlatformException && error.code == 'CANCELED') {
          print('로그인 취소');
          return {
            'statusCode': 500,
            'socialId': '',
          };
        }
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          User user = await UserApi.instance.me();
          print('사용자 정보 요청 성공'
              '\n회원번호: ${user.id}');
          int statusCode = await socialLogin(user.id.toString());
          if (statusCode == 200 || statusCode == 404) {
            setState(() {
              _loginPlatform = LoginPlatform.kakao;
            });
            await _saveLoginPlatform(LoginPlatform.kakao);
          }
          return {
            'statusCode': statusCode,
            'socialId': user.id.toString(),
          };
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
          return {
            'statusCode': 500,
            'socialId': '',
          }; //
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
        User user = await UserApi.instance.me();
        print('사용자 정보 요청 성공'
            '\n회원번호: ${user.id}');
        int statusCode = await socialLogin(user.id.toString());
        if (statusCode == 200 || statusCode == 404) {
          setState(() {
            _loginPlatform = LoginPlatform.kakao;
          });
          await _saveLoginPlatform(LoginPlatform.kakao);
        }
        return {
          'statusCode': statusCode,
          'socialId': user.id.toString(),
        };
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
        return {
          'statusCode': 500,
          'socialId': '',
        }; //
      }
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('try');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print('구글 계정으로 로그인!');
      if (googleUser != null) {
        print('name = ${googleUser.displayName}\n');
        print('name = ${googleUser.email}\n');
        print('name = ${googleUser.id}\n');

        int statusCode = await socialLogin(googleUser.id.toString());
        if (statusCode == 200 || statusCode == 404) {
          setState(() {
            _loginPlatform = LoginPlatform.google;
          });
          await _saveLoginPlatform(LoginPlatform.google);
        }
        return {
          'statusCode': statusCode,
          'socialId': googleUser.id,
        };
      } else {
        return {
          'statusCode': 500,
          'socialId': '',
        };
      }
    } catch (error) {
      print('구글계정으로 로그인 실패 $error');
      return {
        'statusCode': 500,
        'socialId': '',
      }; //
    }
  }

  void signOut() async {
    await SignOutService.signOut(_loginPlatform);
    setState(() {
      _loginPlatform = LoginPlatform.none;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginPlatform');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width / 393;
    double height = MediaQuery.sizeOf(context).height / 852;

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
            const Spacer(
              flex: 5,
            ),
            Text(
              'Log in or sign up to Get Started !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bam.withOpacity(0.7),
                fontFamily: 'BM_Jua',
                fontSize: 18.0 * height,
                fontWeight: FontWeight.w400,
                wordSpacing: 1.1 * width,
              ),
            ),
            SizedBox(
              height: 10 * height,
            ),
            SignInImageButton(
              name: 'Apple',
              onPressed: () async {
                var result = await signInWithApple();
                int statusCode = result['statusCode'];
                String socialId = result['socialId'];
                if (statusCode == 404) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserInputForm(socialId: socialId)));
                } else if (statusCode == 200) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeNav()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(
                CustomIcons.apple_logo,
                size: 20,
                color: Colors.white,
              ),
              textColor: Colors.white,
              buttonColor: Colors.black,
            ),
            SignInImageButton(
              name: 'Kakao',
              onPressed: () async {
                var result = await signInWithKakao();
                int statusCode = result['statusCode'];
                String socialId = result['socialId'];
                if (statusCode == 404) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserInputForm(socialId: socialId)));
                } else if (statusCode == 200) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeNav()),
                    (route) => false,
                  );
                }
              },
              icon: Icon(
                CustomIcons.kakaotalk_icon,
                size: 20,
                color: bam,
              ),
              textColor: bam,
              buttonColor: const Color.fromARGB(255, 254, 229, 0),
            ),
            SignInImageButton(
              name: 'Google',
              onPressed: () async {
                var result = await signInWithGoogle();
                int statusCode = result['statusCode'];
                String socialId = result['socialId'];
                if (statusCode == 404) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserInputForm(socialId: socialId)));
                } else if (statusCode == 200) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeNav()),
                    (route) => false,
                  );
                }
              },
              icon: Icon(
                CustomIcons.google_icon,
                size: 20,
                color: bam,
              ),
              textColor: bam,
              buttonColor: Colors.white,
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

// 소셜로그인 버튼
class SignInImageButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  Icon icon;
  Color textColor, buttonColor;

  SignInImageButton({
    Key? key,
    required this.name,
    required this.onPressed,
    required this.textColor,
    required this.icon,
    required this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height / 852;
    double width = MediaQuery.sizeOf(context).width / 393;

    return Padding(
      padding: EdgeInsets.all(10.0 * height),
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          child: Container(
            height: 50 * height,
            width: 343 * width,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                SizedBox(width: 15 * width),
                Text(
                  'Continue with $name',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'BM_Jua',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
