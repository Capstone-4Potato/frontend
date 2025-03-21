import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/new/models/user_info.dart';
import 'package:flutter_application_1/new/services/api/join_api.dart';
import 'package:flutter_application_1/signup/textfield_decoration.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 회원가입 페이지
class UserInputForm extends StatefulWidget {
  final String socialId;

  const UserInputForm({Key? key, required this.socialId}) : super(key: key);

  @override
  UserInputFormState createState() => UserInputFormState();
}

class UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _fieldKey_1 = GlobalKey<FormFieldState>();
  final _fieldKey_2 = GlobalKey<FormFieldState>();
  final _fieldKey_3 = GlobalKey<FormFieldState>();
  final _fieldKey_4 = GlobalKey<FormFieldState>();

  late String birthYear;
  late int gender;
  late String nickname;
  late int age;
  late int level;

  var isButtonEnabled = List<bool>.filled(4, false);
  var isTapped = List<bool>.filled(4, false);

  final levelMap = {0: 1, 1: 5, 2: 16}; // 레벨에 따른 단계
  final levelLabels = {1: 'Beginner', 5: 'Intermediate', 16: 'Advanced'};

  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _buttonKey = GlobalKey();
  double _buttonTop = 0.0; // 버튼의 y 위치 저장

  void _calculatePosition() {
    final RenderBox renderBoxContainer =
        _containerKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox renderBoxButton =
        _buttonKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      _buttonTop = renderBoxContainer.size.height -
          renderBoxButton.size.height / 2; // 컨테이너 아래 10px 여백
    });
  }

  /// 나이 계산 함수
  void calculateAge() {
    int currentYear = DateTime.now().year;
    int birthYearInt = int.parse(birthYear);
    age = currentYear - birthYearInt + 1;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          backgroundColor: background,
        ),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Container(
                key: _containerKey,
                height: 600.h,
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
                    SizedBox(height: 50.h),
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
                        } else if (year < 1924 || year > DateTime.now().year) {
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
                        color: bam.withValues(alpha: 0.5),
                        fontSize: 20.sp,
                        fontFamily: 'BM_Jua',
                      ),
                      elevation: 16,
                      decoration: textfieldDecoration(
                          isTapped[1], isButtonEnabled[1], 'Gender'),
                      items: <int>[0, 1].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            value == 0 ? 'Male' : 'Female',
                            style: TextStyle(
                              color: bam,
                              fontFamily: 'BM_Jua',
                            ),
                          ),
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
                    SizedBox(height: 10.h),
                    TextFormField(
                      key: _fieldKey_3,
                      style: TextStyle(
                        color: bam,
                        fontSize: 20.h,
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
                    DropdownButtonFormField<int>(
                      key: _fieldKey_4,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color.fromARGB(255, 195, 185, 182),
                      ),
                      dropdownColor: const Color.fromARGB(255, 223, 234, 251),
                      style: TextStyle(
                        color: bam,
                        fontSize: 20.sp,
                        fontFamily: 'BM_Jua',
                      ),
                      elevation: 16,
                      decoration: textfieldDecoration(
                          isTapped[3], isButtonEnabled[3], UserKey.level.name),
                      items: levelLabels.entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        isTapped[3] = true;
                        setState(() {
                          level = newValue!;
                          if (_fieldKey_4.currentState != null) {
                            _fieldKey_4.currentState!.validate()
                                ? isButtonEnabled[3] = true
                                : isButtonEnabled[3] = false;
                          }
                        });
                      },
                      onSaved: (value) {
                        level = value!;
                      },
                      validator: (value) {
                        if (value == null /*|| value.isEmpty*/) {
                          return 'Please select your level.';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: _buttonTop,
                right: 40,
                left: 40,
                child: Center(
                  child: ElevatedButton(
                    key: _buttonKey,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // 회원 가입 api 요청
                        await createUserData(context, nickname, age, gender,
                            level, widget.socialId); // 서버로 데이터 제출
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
                          fontSize: 25.h,
                          fontFamily: 'BM_Jua',
                          color: Colors.white,
                          height: 2.6.h,
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
    );
  }
}
