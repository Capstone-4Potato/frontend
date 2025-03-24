import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/functions/show_common_dialog.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/new/models/user_info.dart';
import 'package:flutter_application_1/new/screens/delete_account_survey_screen.dart';
import 'package:flutter_application_1/new/widgets/custom_app_bar.dart';

/// 회원탈퇴 페이지
class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({
    Key? key,
  }) : super(key: key);
  @override
  WithdrawalScreenState createState() => WithdrawalScreenState();
}

class WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  @override
  void initState() {
    UserInfo().loadUserInfo();
    super.initState();
  }

  /// 닉네임 입력후 처리 함수
  void _attemptWithdrawal() {
    if (_nicknameController.text.isEmpty) {
      _showEmptyFieldDialog();
    } else if (_nicknameController.text == UserInfo().name) {
      // 설문 페이지로 이동
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext buildContext) =>
                  const DeleteAccountSurveyScreen()));
    } else {
      _showErrorDialog();
    }
  }

  // 입력한 닉네임이 사용자 닉넥임과 일치하지 않는다
  void _showErrorDialog() {
    showCommonDialog(context,
        customTitle: "Input Error",
        customContent: "Nickname does not match.",
        customButtonText: "Continue");
  }

  // 닉네임을 입력하지 않음
  void _showEmptyFieldDialog() {
    showCommonDialog(context,
        customTitle: "Input Required",
        customContent: "Please enter your nickname.",
        customButtonText: "Continue");
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const CustomAppBar(),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(height: 140),
              const Text(
                'Are you sure you want to \ndelete your account?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: ' Please enter your nickname',
                    fillColor: Colors.white, // 내부 배경색을 흰색으로 설정
                    filled: true, // 배경색 채우기 활성화
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0), // 둥근 모서리
                      borderSide: const BorderSide(
                        color: Color(0xfff26647), // 테두리 색상 설정
                        width: 2.0, // 테두리 두께 설정
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0), // 포커스 시 둥근 모서리
                      borderSide: const BorderSide(
                        color: Color(0xfff26647), // 포커스 시 테두리 색상 설정
                        width: 2.0, // 포커스 시 테두리 두께 설정
                      ),
                    ),

                    labelStyle: TextStyle(
                      color: bam,
                    ),
                  ),
                  cursorColor: bam,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _attemptWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff26647),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  ' Delete Account ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
