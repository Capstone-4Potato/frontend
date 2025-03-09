import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/models/api_method.dart';
import 'package:flutter_application_1/new/models/navigation_type.dart';
import 'package:flutter_application_1/new/screens/login_screen.dart';
import 'package:flutter_application_1/new/services/api/api_service.dart';
import 'package:flutter_application_1/new/services/login_platform_manage.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_application_1/new/services/tutorial_initializer.dart';
import 'package:flutter_application_1/new/utils/navigation_extension.dart';
import 'package:flutter_application_1/new/utils/response_printer.dart';
import 'package:flutter_application_1/new/widgets/dialogs/ask_recover_dialog.dart';
import 'package:flutter_application_1/new/widgets/dialogs/recording_error_dialog.dart';
import 'package:http/http.dart' as http;

/// ### POST `/logout` : 로그아웃
Future<void> sendLogoutRequest(BuildContext context) async {
  try {
    await apiRequest(
        endpoint: 'logout',
        method: ApiMethod.post.type,
        requiresAuth: true,
        autoRefresh: true,
        onSuccess: (response) {
          // 토큰 삭제
          deleteTokens();
          // 유저 정보 초기화
          initiallizeTutoInfo(true);
          // 로그인 화면으로 이동
          context.navigateTo(
              screen: const LoginScreen(),
              type: NavigationType.pushAndRemoveUntil);
          // 로그인 플랫폼 삭제
          removeLoginPlatform();
        },
        onError: (statusCode, message) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const RecordingErrorDialog(text: 'Failed to logout');
            },
          );
        });
  } catch (e) {
    debugPrint("로그아웃 Error: $e");
  }
}

/// ### POST `/login` : 로그인
Future<int> sendSocialLoginRequest(
    BuildContext context, String? socialId) async {
  String url = '$main_url/login';
  var urlParse = Uri.parse(url);

  try {
    var request = http.MultipartRequest(ApiMethod.post.type, urlParse);
    request.fields['socialId'] = socialId!;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    debugPrint("응답 : ${response.body}");

    if (response.statusCode == 200) {
      // Assuming 'access' is the key for the access token in headers
      String? accessToken = response.headers['access'];
      String? refreshToken = response.headers['refresh'];

      responsePrinter(url, response.body, ApiMethod.post.type);

      if (accessToken != null && refreshToken != null) {
        await saveTokens(accessToken, refreshToken);
      }
    } else if (response.statusCode == 403) {
      // ignore: use_build_context_synchronously
      askRecoverDialog(context, socialId);
    }

    return response.statusCode; // Return the status code
  } catch (e) {
    debugPrint('Network error occurred: $e');
    return 500; // Assume server error on exception
  }
}
