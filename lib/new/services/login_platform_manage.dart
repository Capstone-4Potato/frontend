import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/new/models/login_platform.dart';
import 'package:flutter_application_1/new/models/shared_preferences_key.dart';

/// 로그인 플랫폼 불러옴
Future<void> loadLoginPlatform() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.getInt(SharedPreferencesKey.loginPlatform.name);
}

/// 로그인 플랫폼 저장
Future<void> saveLoginPlatform(LoginPlatform platform) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(SharedPreferencesKey.loginPlatform.name, platform.index);
  debugPrint("로그인 플랫폼 : $prefs, ${platform.index} ");
}

/// 로그인 플랫폼 삭제
Future<void> removeLoginPlatform() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(SharedPreferencesKey.loginPlatform.name);
}
