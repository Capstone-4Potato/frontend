import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/profile/logout/sign_out_social.dart';
import 'package:flutter_application_1/signup/signup_screen.dart';
import 'package:flutter_application_1/login/login_platform.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
    var url = Uri.parse('http://potato.seatnullnull.com/login');

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Image.asset(
              'assets/bam.png',
              width: 100,
              height: MediaQuery.of(context).size.height * 0.12,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 26),
              child: Text(
                'Log in or sign up to get started',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SignInImageButton(
              assetName: 'assets/engapple.png',
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
                    MaterialPageRoute(builder: (context) => MainPage()),
                    (route) => false,
                  );
                }
              },
            ),
            SignInImageButton(
              assetName: 'assets/engkakao.png',
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
                    MaterialPageRoute(builder: (context) => MainPage()),
                    (route) => false,
                  );
                }
              },
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

// 소셜로그인이미지 버튼
class SignInImageButton extends StatelessWidget {
  final String assetName;
  final VoidCallback onPressed;

  const SignInImageButton({
    Key? key,
    required this.assetName,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: onPressed,
        child: Image.asset(
          assetName,
          width: double.infinity, // Set the image to the width of the screen
          height: 50, // Set the image height
          fit: BoxFit.contain, // Cover the button area
        ),
      ),
    );
  }
}
