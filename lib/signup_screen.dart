import 'package:flutter/material.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/profile/tutorial.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInputForm extends StatefulWidget {
  final String socialId;

  const UserInputForm({Key? key, required this.socialId}) : super(key: key);

  @override
  _UserInputFormState createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  late String birthYear;
  late int gender;
  late String nickname;
  late int age;

  void calculateAge() {
    int currentYear = DateTime.now().year;
    int birthYearInt = int.parse(birthYear);
    age = currentYear - birthYearInt + 1;
  }

  Future<void> signup() async {
    Uri url = Uri.parse('http://potato.seatnullnull.com/users');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'socialId': widget.socialId,
          'age': age,
          'gender': gender,
          'name': nickname,
        }),
      );
      //print(1234567);
      switch (response.statusCode) {
        case 200:
          print(response.body);
          String? accessToken = response.headers['access'];
          String? refreshToken = response.headers['refresh'];
          print(accessToken);
          print(refreshToken);
          if (accessToken != null && refreshToken != null) {
            // 사용자별로 토큰 저장
            await saveTokens(accessToken, refreshToken);
            // socialId를 현재 사용자 식별자로 저장
            // await saveUserIdentifier(socialId);
          }
          break;

        case 500:
          print(response.body);
          // 오류 처리 로직, 예를 들어 사용자에게 오류 알림 등
          break;
        default:
          print('알 수 없는 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
          // 기타 상태 코드에 대한 처리
          break;
      }
    } catch (e) {
      print('네트워크 오류가 발생했습니다: $e');
      // 네트워크 예외 처리 로직
    }
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  // SizedBox(height: 10),
                  Text(
                    'Almost done!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'For effective Korean pronunciation correction,\nwe provide voices tailored to your age and gender.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Birth Year',
                      fillColor: Colors.white, // 내부 배경색을 흰색으로 설정
                      filled: true, // 배경색 채우기 활성화
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ), // 모서리를 더 둥글게
                      focusedBorder: OutlineInputBorder(
                        // 포커스 상태일 때의 테두리 스타일
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Color(0xFFF26647), // 테두리 색상 변경
                          width: 1.5, // 테두리 너비
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0), // 내부 여백 설정
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      birthYear = value!;
                      calculateAge();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your birth year.';
                      }
                      int? year = int.tryParse(value);
                      if (year == null) {
                        return 'Please enter your birth year.';
                      } else if (year > DateTime.now().year) {
                        return 'Please enter your birth year.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      fillColor: Colors.white, // 내부 배경색을 흰색으로 설정
                      filled: true, // 배경색 채우기 활성화
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // 포커스 상태일 때의 테두리 스타일
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Color(0xFFF26647), // 테두리 색상 변경
                          width: 1.5, // 테두리 너비
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0),
                    ),
                    items: <int>[0, 1].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value == 0 ? 'Male' : 'Female'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        gender = newValue!;
                      });
                    },
                    onSaved: (value) {
                      gender = value!;
                    },
                    validator: (value) {
                      if (value == null /*|| value.isEmpty*/) {
                        return 'Please select your gender.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nickname',
                      fillColor: Colors.white, // 내부 배경색을 흰색으로 설정
                      filled: true, // 배경색 채우기 활성화
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // 포커스 상태일 때의 테두리 스타일
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Color(0xFFF26647), // 테두리 색상 변경
                          width: 1.5, // 테두리 너비
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0),
                    ),
                    onSaved: (value) {
                      nickname = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your nickname.';
                      } else if (value.length < 3) {
                        return 'Nickname must be at least 3 characters.';
                      } else if (value.length > 8) {
                        return 'Nickname must be at most 8 characters.';
                      } else if (value.contains(' ')) {
                        return 'Nickname cannot contain spaces.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        signup(); // 서버로 데이터 제출

                        //튜토리얼로 이동
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TutorialScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: Text('Submit',
                        style: TextStyle(
                            fontSize: 20, color: Colors.white)), // 텍스트 크기 조정
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF26647), // 버튼 배경색 설정
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
