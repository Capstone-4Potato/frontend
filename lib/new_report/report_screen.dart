import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/login/login_platform.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/profile/editprofile/editprofile_screen.dart';
import 'package:flutter_application_1/profile/tutorial/retutorial.dart';
import 'package:flutter_application_1/profile/logout/sign_out_social.dart';
import 'package:flutter_application_1/profile/logout/signout.dart';
import 'package:flutter_application_1/profile/deleteaccount/withdrawal_screen.dart';
import 'package:flutter_application_1/login/login_screen.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static String? nickname;
  static int? age;
  static int? gender;
  bool isLoading = true;
  LoginPlatform _loginPlatform = LoginPlatform.none; // Add this line

  @override
  void initState() {
    super.initState();
    _loadLoginPlatform();

    if (nickname == null || age == null || gender == null) {
      userData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadLoginPlatform() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginPlatform = LoginPlatform.values[prefs.getInt('loginPlatform') ?? 4];
    });
  }

  // 회원정보 받기 API
  Future<void> userData() async {
    String? token = await getAccessToken();
    var url = Uri.parse('$main_url/users');

    // Function to make the get request
    Future<http.Response> makeGetRequest(String token) {
      return http.get(
        url,
        headers: <String, String>{
          'access': token,
          'Content-Type': 'application/json',
        },
      );
    }

    try {
      var response = await makeGetRequest(token!);

      if (response.statusCode == 200) {
        print(response.body);
        var data = json.decode(response.body);
        setState(() {
          nickname = data['name'];
          age = data['age'];
          gender = data['gender'];
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh the token
        print('Access token expired. Refreshing token...');

        // Refresh the access token
        bool isRefreshed = await refreshAccessToken();
        if (isRefreshed) {
          // Retry the get request with the new token
          token = await getAccessToken();
          response = await makeGetRequest(token!);

          if (response.statusCode == 200) {
            print(response.body);
            var data = json.decode(response.body);
            setState(() {
              nickname = data['name'];
              age = data['age'];
              gender = data['gender'];
              isLoading = false;
            });
          } else {
            throw Exception('Failed to fetch user data after refreshing token');
          }
        } else {
          throw Exception('Failed to refresh access token');
        }
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Network error occurred: $e');
    }
  }

  void _updateUserProfile(String newNickname, int newAge, int newGender) {
    setState(() {
      nickname = newNickname;
      age = newAge;
      gender = newGender;
    });
  }

  void _resetUserProfile() {
    setState(() {
      nickname = null;
      age = null;
      gender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 852;
    double width = MediaQuery.of(context).size.width / 392;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        backgroundColor: background,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF26647)),
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Hello,\n',
                            style: const TextStyle(fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                text: '$nickname 👋',
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor:
                                const Color.fromARGB(255, 242, 235, 227),
                            child: Image.asset(
                              'assets/image/bam_character.png',
                              width: 65 * width,
                              height: 65 * height,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 35,
                                backgroundColor:
                                    Color.fromARGB(255, 242, 235, 227),
                                child: Text(
                                  '🕰️',
                                  style: TextStyle(
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              const Text(
                                'Study Time',
                                style: TextStyle(
                                  color: Color(0xFF5E5D58),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: 'Hello,\n',
                                  style: const TextStyle(fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '$nickname 👋',
                                      style: const TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        const SizedBox(height: 40),
                        _buildRoundedTile(
                            'Edit profile', Icons.arrow_forward_ios, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileUpdatePage(
                                currentnickname: nickname ?? '',
                                currentage: age ?? -100,
                                currentgender: gender ?? -1,
                                onProfileUpdate: _updateUserProfile,
                              ),
                            ),
                          );
                        }),
                        _buildRoundedTile('Tutorial', Icons.arrow_forward_ios,
                            onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RetutorialScreen(),
                            ),
                          );
                        }),
                        _buildRoundedTile('Log out', Icons.arrow_forward_ios,
                            onTap: () {
                          _showLogoutDialog(context);
                        }),
                        _buildRoundedTile(
                            'Delete account', Icons.arrow_forward_ios,
                            onTap: () {
                          _showDeleteAccountDialog(context);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRoundedTile(String title, IconData icon,
      {required Function onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.02,
              fontWeight: FontWeight.w500),
        ),
        trailing: Icon(icon),
        onTap: () => onTap(),
      ),
    );
  }

  // 로그아웃 다이알로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height / 852;
        final double width = MediaQuery.of(context).size.width / 393;

        return Dialog(
          alignment: Alignment.center,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 26,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 340 * width,
            height: 230 * height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 106, 106, 106),
                    ),
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        print(
                            'Current login platform: $_loginPlatform'); // Add this line
                        await SignOutService.signOut(
                            _loginPlatform); // 소셜로그인 로그아웃하기
                        signout(); // 앱 로그아웃하기
                        _resetUserProfile();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('loginPlatform');
                      },
                      child: Container(
                        width: 263 * width,
                        height: 46 * height,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                            child: Text(
                          'Log out',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 12.0),
                        width: 263 * width,
                        height: 46 * height,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color.fromARGB(255, 190, 189, 184)),
                        ),
                        child: const Center(
                            child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: const Color.fromARGB(255, 21, 21, 21).withOpacity(0.6),
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height / 852;
        final double width = MediaQuery.of(context).size.width / 393;

        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          alignment: Alignment.center,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 250,
          ),
          child: Container(
            width: 340 * width,
            height: 280 * height,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 21, 21, 21).withOpacity(0.01),
                borderRadius: BorderRadius.circular(20)),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 40, bottom: 15, right: 24, left: 24),
                    width: 340 * width,
                    height: 220 * height,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 237, 232, 244),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Are you sure?',
                          style: TextStyle(
                            color: accent,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'If you proceed, you will lose all your\npersonal data. Are you sure you want to\ndelete your account?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 150, 150, 150),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 140 * width,
                                height: 46 * height,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 206, 201, 214),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                    child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WithdrawalScreen(
                                      nickname: nickname ?? '',
                                      onProfileReset: _resetUserProfile,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 140 * width,
                                height: 46 * height,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                    child: Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 132,
                  left: 132,
                  child: Container(
                    width: 76 * width,
                    height: 76 * height,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 237, 232, 244),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: const Color.fromARGB(255, 111, 111, 111),
                        width: 5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          color: accent,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
