import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/login/login_screen.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 방향 고정
  await SystemChrome.setPreferredOrientations([
    //DeviceOrientation.portraitUp,
  ]);
  KakaoSdk.init(nativeAppKey: 'ㅇㅇ');
  Widget initialScreen = await _checkTokenStatus();

  runApp(MyApp(initialScreen: initialScreen));
}

// 비동기 작업을 통해 토큰 상태를 확인하는 함수
Future<Widget> _checkTokenStatus() async {
  // Refresh Token이 있는지 확인
  String? refreshToken = await getRefreshToken();

  if (refreshToken != null) {
    // Refresh Token이 있으면 Access Token 재발급 시도
    bool isRefreshed = await refreshAccessToken();
    if (isRefreshed) {
      // 재발급에 성공하면 홈 화면으로 이동
      return MainPage();
    } else {
      // 재발급 실패 시 로그인 화면으로 이동
      return const LoginScreen();
    }
  } else {
    // Refresh Token이 없으면 로그인 화면으로 이동
    return const LoginScreen();
  }
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'BM_Jua',
      ),
      home: initialScreen,
    );
  }
}
