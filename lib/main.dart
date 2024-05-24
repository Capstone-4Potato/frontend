import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
//import 'package:flutter_naver_login/flutter_naver_login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: '1dd4ee9a5ed2afb5fe8f7590fa690198');
  // FlutterNaverLogin.init(
  //   clientId: 'YOUR_CLIENT_ID',
  //   clientSecret: 'YOUR_CLIENT_SECRET',
  //   clientName: 'YOUR_CLIENT_NAME',
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}
