import 'package:flutter/material.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/profile/deleteaccount/deleteaccount.dart';
import 'package:flutter_application_1/login/login_screen.dart';

// 회원탈퇴 페이지
class WithdrawalScreen extends StatefulWidget {
  final String nickname;
  final Function() onProfileReset;

  WithdrawalScreen(
      {Key? key, required this.nickname, required this.onProfileReset})
      : super(key: key);
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

  // 회원탈퇴 성공
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Success"),
        content: Text(
          "Account deletion is complete.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              deleteaccount(_nicknameController.text);
              widget.onProfileReset();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text(
              "OK",
              style: TextStyle(color: Color(0xFFF26647), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 입력한 닉네임이 사용자 닉넥임과 일치하지 않는다
  void _showErrorDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(
          "Nickname does not match.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "OK",
              style: TextStyle(color: Color(0xFFF26647), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 닉네임을 입력하지 않음
  void _showEmptyFieldDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Input Required"),
        content: Text(
          "Please enter your nickname.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "OK",
              style: TextStyle(color: Color(0xFFF26647), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
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
              SizedBox(height: 140),
              Text(
                'Are you sure you want to \ndelete your account?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
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
                      borderSide: BorderSide(
                        color: const Color(0xfff26647), // 테두리 색상 설정
                        width: 2.0, // 테두리 두께 설정
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0), // 포커스 시 둥근 모서리
                      borderSide: BorderSide(
                        color: const Color(0xfff26647), // 포커스 시 테두리 색상 설정
                        width: 2.0, // 포커스 시 테두리 두께 설정
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _attemptWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff26647),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
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
