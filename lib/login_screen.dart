import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/profile/sign_out_social.dart';
import 'package:flutter_application_1/signup_screen.dart';
import 'package:flutter_application_1/login_platform.dart';
import 'package:flutter_application_1/token.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
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
        print(accessToken);
        if (accessToken != null) {
          await saveAccessToken(accessToken); // Save access token
        }
      }
      print(response.statusCode);
      print('Response body: ${response.body}'); // Log the response body
      print(
          'Response headers: ${response.headers}'); // Log the response headers

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

      //print('credential.state = $credential');
      //print('credential.state = ${credential.email}');
      // print('credential.state = ${credential.userIdentifier}');

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
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      var response = await http.get(
        Uri.https('kapi.kakao.com', '/v2/user/me'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}'
        },
      );
      final profileInfo = json.decode(response.body);
      //print(profileInfo['id']);
      int statusCode = await socialLogin(profileInfo['id'].toString());
      if (statusCode == 200 || statusCode == 404) {
        setState(() {
          _loginPlatform = LoginPlatform.kakao;
        });
        await _saveLoginPlatform(LoginPlatform.kakao);
      }
      return {
        'statusCode': statusCode,
        'socialId': profileInfo['id'].toString(),
      };
    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');
      return {
        'statusCode': 500,
        'socialId': '',
      }; // Return error code on exception
    }
  }

  Future<Map<String, dynamic>> signInWithNaver() async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      int statusCode = await socialLogin(res.account.id);
      if (statusCode == 200 || statusCode == 404) {
        setState(() {
          _loginPlatform = LoginPlatform.naver;
        });
        await _saveLoginPlatform(LoginPlatform.naver);
      }
      return {
        'statusCode': statusCode,
        'socialId': res.account.id,
      };
    } catch (error) {
      print(error);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text(
              '발밤발밤',
              //textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF26647),
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'BalbamBalbam',
              //textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFD86F41),
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Log in to access a variety of services',
                //textAlign: TextAlign.center,
                // '로그인하고 다양한 서비스를 이용하세요!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
            ),
            Spacer(),
            SignInImageButton(
              assetName: 'assets/apple.png',
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
            // SignInImageButton(
            //   assetName: 'assets/google.png',
            //   onPressed: () {},
            // ),
            SignInImageButton(
              assetName: 'assets/kakao.png',
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
            SignInImageButton(
              assetName: 'assets/naver.png',
              onPressed: () async {
                var result = await signInWithNaver();
                int statusCode = result['statusCode'];
                String socialId = result['socialId'];
                print(statusCode);
                if (statusCode == 404) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserInputForm(socialId: socialId)));
                } else if (statusCode == 200) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainPage()));
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
