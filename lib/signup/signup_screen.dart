import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/signup/textfield_decoration.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_application_1/report/vulnerablesoundtest/starting_test_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// 회원가입 페이지
class UserInputForm extends StatefulWidget {
  final String socialId;

  const UserInputForm({Key? key, required this.socialId}) : super(key: key);

  @override
  _UserInputFormState createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _fieldKey_1 = GlobalKey<FormFieldState>();
  final _fieldKey_2 = GlobalKey<FormFieldState>();
  final _fieldKey_3 = GlobalKey<FormFieldState>();
  late String birthYear;
  late int gender;
  late String nickname;
  late int age;
  var isButtonEnabled = List<bool>.filled(3, false);
  var isTapped = List<bool>.filled(3, false);

  void calculateAge() {
    int currentYear = DateTime.now().year;
    int birthYearInt = int.parse(birthYear);
    age = currentYear - birthYearInt + 1;
  }

  // 회원가입 API
  Future<void> signup() async {
    Uri url = Uri.parse('$main_url/users');
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
      switch (response.statusCode) {
        case 200:
          print(response.body);
          String? accessToken = response.headers['access'];
          String? refreshToken = response.headers['refresh'];
          print(accessToken);
          print(refreshToken);
          if (accessToken != null && refreshToken != null) {
            // 토큰 저장
            await saveTokens(accessToken, refreshToken);
          }
          break;

        case 500:
          print(response.body);
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
    double width = MediaQuery.sizeOf(context).width / 393;
    double height = MediaQuery.sizeOf(context).height / 852;

    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          backgroundColor: background,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Container(
                  height: 597.h,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: const BorderRadiusDirectional.only(
                      bottomStart: Radius.circular(40),
                      bottomEnd: Radius.circular(40),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0.h),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      Text(
                        'Almost Done!',
                        style: TextStyle(
                          color: bam,
                          fontSize: 30.0.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'For effective Korean pronunciation correction,\nwe provide voices tailored to your age and gender.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primary,
                          fontSize: 14.0.sp,
                        ),
                      ),
                      SizedBox(height: 75.h),
                      TextFormField(
                        key: _fieldKey_1,
                        style: TextStyle(
                          color: bam,
                          fontSize: 20.sp,
                        ),
                        decoration: textfieldDecoration(
                            isTapped[0], isButtonEnabled[0], 'Birth Year'),
                        cursorColor: bam,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          isTapped[0] = true;
                          setState(() {
                            if (_fieldKey_1.currentState != null) {
                              _fieldKey_1.currentState!.validate()
                                  ? isButtonEnabled[0] = true
                                  : isButtonEnabled[0] = false;
                            }
                          });
                        },
                        onSaved: (value) {
                          birthYear = value!;
                          calculateAge();
                        },
                        validator: (value) {
                          int? year = int.tryParse(value!);
                          if (year == null) {
                            return 'Please enter a valid year.';
                          } else if (year < 1924 ||
                              year > DateTime.now().year) {
                            return 'Please enter your birth year.';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<int>(
                        key: _fieldKey_2,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color.fromARGB(255, 195, 185, 182),
                        ),
                        dropdownColor: const Color.fromARGB(255, 223, 234, 251),
                        style: TextStyle(
                          color: bam,
                          fontSize: 20.sp,
                        ),
                        elevation: 16,
                        decoration: textfieldDecoration(
                            isTapped[1], isButtonEnabled[1], 'Gender'),
                        items: <int>[0, 1].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value == 0 ? 'Male' : 'Female'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          isTapped[1] = true;
                          setState(() {
                            gender = newValue!;
                            if (_fieldKey_2.currentState != null) {
                              _fieldKey_2.currentState!.validate()
                                  ? isButtonEnabled[1] = true
                                  : isButtonEnabled[1] = false;
                            }
                          });
                        },
                        onSaved: (value) {
                          gender = value!;
                        },
                        validator: (value) {
                          if (value == null /*|| value.isEmpty*/) {
                            return 'Please select your gender.';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 10 * height),
                      TextFormField(
                        key: _fieldKey_3,
                        style: TextStyle(
                          color: bam,
                          fontSize: 20 * height,
                        ),
                        decoration: textfieldDecoration(
                            isTapped[2], isButtonEnabled[2], 'Nickname'),
                        cursorColor: bam,
                        onChanged: (value) {
                          isTapped[2] = true;
                          setState(() {
                            if (_fieldKey_3.currentState != null) {
                              _fieldKey_3.currentState!.validate()
                                  ? isButtonEnabled[2] = true
                                  : isButtonEnabled[2] = false;
                            }
                          });
                        },
                        onSaved: (value) {
                          nickname = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your nickname.';
                          } else if (value.length < 3) {
                            return 'Nickname must be at least 3 characters.';
                          } else if (value.length > 10) {
                            return 'Nickname must be at most 10 characters.';
                          } else if (value.contains(' ')) {
                            return 'Nickname cannot contain spaces.';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 110.h),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 40,
                  left: 40,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          await signup(); // 서버로 데이터 제출
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setInt(
                              'homeTutorialStep', 1); // 기본값은 1 (첫 번째 단계)
                          prefs.setInt(
                              'reportTutorialStep', 1); // 기본값은 1 (첫 번째 단계)
                          prefs.setInt('learningCourseTutorialStep',
                              1); // 기본값은 1 (첫 번째 단계)
                          //튜토리얼로 이동
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StartTestScreen()),
                            (route) => false,
                          );
                        }
                      }, // 텍스트 크기 조정
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonEnabled[0] &&
                                isButtonEnabled[1] &&
                                isButtonEnabled[2]
                            ? const Color.fromARGB(255, 232, 120, 71)
                            : const Color.fromARGB(255, 246, 202, 182),
                        elevation: 4,
                      ),
                      child: Center(
                        child: Text(
                          'Submit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25 * height,
                            fontFamily: 'BM_Jua',
                            color: Colors.white,
                            height: 2.6 * height,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
