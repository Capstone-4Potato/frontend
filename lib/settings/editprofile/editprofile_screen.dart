import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/signup/textfield_decoration.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_application_1/widgets/success_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

// 회원정보 수정 페이지
class ProfileUpdatePage extends StatefulWidget {
  final String currentnickname;
  final int currentage;
  final int currentgender;
  final Function(String, int, int) onProfileUpdate;

  const ProfileUpdatePage({
    Key? key,
    required this.currentnickname,
    required this.currentage,
    required this.currentgender,
    required this.onProfileUpdate,
  }) : super(key: key);

  @override
  _ProfileUpdatePageState createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _fieldKey_1 = GlobalKey<FormFieldState>();
  final _fieldKey_2 = GlobalKey<FormFieldState>();
  final _fieldKey_3 = GlobalKey<FormFieldState>();
  late TextEditingController _nicknameController;
  late TextEditingController _birthYearController;
  late int? _selectedGender;
  late int currentbirthyear;
  var isButtonEnabled = List<bool>.filled(3, false);
  var isTapped = List<bool>.filled(3, false);

  @override
  void initState() {
    super.initState();
    currentbirthyear = DateTime.now().year - widget.currentage + 1;
    _nicknameController = TextEditingController(text: widget.currentnickname);
    _birthYearController =
        TextEditingController(text: currentbirthyear.toString());
    _selectedGender = widget.currentgender;
  }

  // 회원정보 수정 API
  Future<void> _updateProfile() async {
    // 토큰을 가져오는 함수를 별도 메서드로 분리
    Future<String?> fetchAccessToken() async {
      return await getAccessToken();
    }

    // 요청을 보내는 함수를 별도 메서드로 분리
    Future<http.Response> makeRequest(String token) async {
      var url = Uri.parse('$main_url/users');
      return await http.patch(
        url,
        headers: <String, String>{
          'access': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nicknameController.text,
          'age': DateTime.now().year - int.parse(_birthYearController.text) + 1,
          'gender': _selectedGender,
        }),
      );
    }

    // 요청을 보낼 때 사용할 액세스 토큰
    String? token = await fetchAccessToken();
    if (_formKey.currentState?.validate() ?? false) {
      var response = await makeRequest(token!);

      if (response.statusCode == 200) {
        print("Info updated successfully: ${response.body}");
        widget.onProfileUpdate(
          _nicknameController.text,
          DateTime.now().year - int.parse(_birthYearController.text) + 1,
          _selectedGender!,
        );
        _showSuccessDialog();
      } else if (response.statusCode == 401) {
        // 토큰이 만료된 경우
        print('Access token expired. Refreshing token...');

        // 리프레시 토큰을 사용하여 새로운 액세스 토큰을 가져옵니다.
        bool isRefreshed = await refreshAccessToken();

        if (isRefreshed) {
          // 새로운 액세스 토큰으로 다시 시도
          print('Token refreshed successfully. Retrying request...');
          String? newToken = await fetchAccessToken();
          response = await makeRequest(newToken!);

          if (response.statusCode == 200) {
            print('프로필 변경 성공');
          } else {
            print('프로필 변경 실패');
          }
        } else {
          print('Failed to refresh token. Please log in again.');
        }
      } else {
        // 다른 상태 코드에 대한 처리
        print('Failed to update bookmark. Status code: ${response.statusCode}');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SuccessDialog(
          subtitle: 'Your profile has been updated successfully.',
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
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
          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: bam,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: background,
        ),
        backgroundColor: primary,
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
                      SizedBox(height: 80.h),
                      TextFormField(
                        controller: _birthYearController,
                        key: _fieldKey_1,
                        decoration: textfieldDecoration(
                            isTapped[0], isButtonEnabled[0], 'Birth Year'),
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
                        validator: (value) {
                          int? year = int.tryParse(value!);
                          print(year);
                          if (year == null) {
                            return 'Please enter a valid year.';
                          } else if (year < 1924 ||
                              year > DateTime.now().year) {
                            return 'Please enter your birth year.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 25.h),
                      DropdownButtonFormField<int>(
                        value: _selectedGender,
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
                        items: <int>[0, 1].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value == 0 ? 'Male' : 'Female'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        decoration: textfieldDecoration(
                            isTapped[1], isButtonEnabled[1], 'Gender'),
                      ),
                      SizedBox(height: 25.h),
                      TextFormField(
                        controller: _nicknameController,
                        key: _fieldKey_3,
                        decoration: textfieldDecoration(
                            isTapped[2], isButtonEnabled[2], 'Nickname'),
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
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 232, 120, 71),
                        elevation: 4,
                      ),
                      child: Text(
                        'Edit Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.sp,
                          color: Colors.white,
                          height: 2.6.h,
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
