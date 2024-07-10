import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

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
  late TextEditingController _nicknameController;
  late TextEditingController _birthYearController;
  late int? _selectedGender;
  late int currentbirthyear;

  @override
  void initState() {
    super.initState();
    currentbirthyear = DateTime.now().year - widget.currentage + 1;
    _nicknameController = TextEditingController(text: widget.currentnickname);
    _birthYearController =
        TextEditingController(text: currentbirthyear.toString());
    _selectedGender = widget.currentgender;
  }

  Future<void> _updateProfile() async {
    // 토큰을 가져오는 함수를 별도 메서드로 분리
    Future<String?> fetchAccessToken() async {
      return await getAccessToken();
    }

    // 요청을 보내는 함수를 별도 메서드로 분리
    Future<http.Response> makeRequest(String token) async {
      var url = Uri.parse('http://potato.seatnullnull.com/users');
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

  // if (_formKey.currentState?.validate() ?? false) {
  //   String? token = await getAccessToken();
  //   var url = Uri.parse('http://potato.seatnullnull.com/users');

  //   try {
  //     var response = await http.patch(
  //       url,
  //       headers: <String, String>{
  //         'access': '$token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'name': _nicknameController.text,
  //         'age':
  //             DateTime.now().year - int.parse(_birthYearController.text) + 1,
  //         'gender': _selectedGender,
  //       }),
  //     );
  //     if (response.statusCode == 200) {
  //       print("Info updated successfully: ${response.body}");
  //       widget.onProfileUpdate(
  //         _nicknameController.text,
  //         DateTime.now().year - int.parse(_birthYearController.text) + 1,
  //         _selectedGender!,
  //       );
  //       _showSuccessDialog();
  //     } else if (response.statusCode == 401) {
  //       // 토큰이 만료된 경우
  //       print('Access token expired. Refreshing token...');

  //       // 리프레시 토큰을 사용하여 새로운 액세스 토큰을 가져옵니다.
  //       bool isRefreshed = await refreshAccessToken();
  //     } else {
  //       print(
  //           "Failed to update info: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error updating info: $e");
  //   }
  // }
// }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(
            'Your profile has been updated successfully.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Color(0xFFF26647), fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainPage(initialIndex: 3)),
                  (route) => false,
                );
              },
            ),
          ],
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
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFFF5F5F5),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                SizedBox(height: 80),
                TextFormField(
                  controller: _birthYearController,
                  decoration: InputDecoration(
                    labelText: 'Birth Year',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Color(0xFFF26647),
                        width: 1.5,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your birth year.';
                    }
                    int? year = int.tryParse(value);
                    if (year == null) {
                      return 'Please enter a valid year.';
                    } else if (year > DateTime.now().year) {
                      return 'Please enter a valid year.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25),
                DropdownButtonFormField<int>(
                  value: _selectedGender,
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Male'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Female'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Color(0xFFF26647),
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  dropdownColor: Colors.white,
                ),
                SizedBox(height: 25),
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Nickname',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Color(0xFFF26647),
                        width: 1.5,
                      ),
                    ),
                  ),
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
                SizedBox(height: 60),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff26647),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white),
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
