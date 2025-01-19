import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/settings/deleteaccount/deleteaccount.dart';
import 'package:flutter_application_1/login/login_screen.dart';
import 'package:flutter_application_1/widgets/recording_error_dialog.dart';
import 'package:flutter_application_1/widgets/success_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 회원탈퇴 페이지
class WithdrawalScreen extends StatefulWidget {
  final String nickname;
  final Function() onProfileReset;

  const WithdrawalScreen({
    Key? key,
    required this.nickname,
    required this.onProfileReset,
  }) : super(key: key);
  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  void _attemptWithdrawal() {
    if (_nicknameController.text.isEmpty) {
      _showEmptyFieldDialog();
    } else if (_nicknameController.text == widget.nickname) {
      _showSuccessDialog();
    } else {
      _showErrorDialog();
    }
  }

  // 학습한 카드 갯수 불러오기
  Future<void> loadLearnedCardCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 정보 초기화
    await prefs.setInt('learnedCardCount', 0);
    await prefs.setInt('totalCard', 10);
    await prefs.setBool('checkTodayCourse', false);
    await prefs.setInt('homeTutorialStep', 1);
    await prefs.setInt('reportTutorialStep', 1);
    await prefs.setInt('learningCourseTutorialStep', 1);
    await prefs.setInt('feedbackTutorialStep', 1);
    await prefs.remove('cardIdList');
  }

  // 회원탈퇴 성공
  void _showSuccessDialog() {
    loadLearnedCardCount();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          subtitle: "Account deletion is complete.",
          onTap: () {
            deleteaccount(_nicknameController.text);
            widget.onProfileReset();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        );
      },
    );
  }

  // 입력한 닉네임이 사용자 닉넥임과 일치하지 않는다
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecordingErrorDialog(
          title: "Error",
          text: "Nickname does not match.",
        );
      },
    );
  }

  // 닉네임을 입력하지 않음
  void _showEmptyFieldDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecordingErrorDialog(
          title: "Input Required",
          text: "Please enter your nickname.",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFFF5F5F5),
        ),
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
