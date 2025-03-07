import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/icons/custom_icons.dart';
import 'package:flutter_application_1/new/models/login_platform.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/services/login_platform_manage.dart';
import 'package:flutter_application_1/settings/editprofile/editprofile_screen.dart';
import 'package:flutter_application_1/tutorial/retutorial.dart';
import 'package:flutter_application_1/settings/logout/sign_out_social.dart';
import 'package:flutter_application_1/new/services/api/login_api.dart';
import 'package:flutter_application_1/settings/deleteaccount/withdrawal_screen.dart';
import 'package:flutter_application_1/new/screens/login_screen.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static String? nickname;
  static int? age;
  static int? gender;
  bool isLoading = true;
  LoginPlatform _loginPlatform = LoginPlatform.none; // Add this line

  @override
  void initState() {
    super.initState();

    if (nickname == null || age == null || gender == null) {
      userData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
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

  void _updateUserProfile(
      String newNickname, int newAge, int newGender, int newLevel) {
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
    return Scaffold(
      appBar: AppBar(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: bam,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: const Color(0xFFF2EBE3),
        bottom: PreferredSize(
          preferredSize: Size(392.w, 84.h),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: bam,
                    fontSize: 36.w,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF26647)),
            ))
          : ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: 44.0.w, right: 44.0.w, top: 16.h, bottom: 10.h),
                  child: const Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Divider(
                  color: Color(0xFFBEBDB8),
                ),
                _buildSettingsItem('Edit profile', CustomIcons.profile_icon,
                    onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileUpdatePage(),
                    ),
                  );
                }),
                _buildSettingsItem('Log out', CustomIcons.logout_icon,
                    onTap: () {
                  _showLogoutDialog(context);
                }),
                _buildSettingsItem('Delete account', CustomIcons.trashcan_icon,
                    onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WithdrawalScreen(),
                    ),
                  );
                }),
                Padding(
                  padding: EdgeInsets.only(
                    left: 44.0.w,
                    right: 44.0.w,
                    top: 16.h,
                    bottom: 10.h,
                  ),
                  child: const Text(
                    'Tutorial',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Divider(
                  color: Color(0xFFBEBDB8),
                ),
                _buildSettingsItem('Tutorial', CustomIcons.tutorial_icon,
                    onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RetutorialScreen(),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon, {
    required Function onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.h, vertical: 0),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
      ),
      child: ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 17.0.w),
          child: Icon(
            icon,
            color: Colors.black,
            size: 20.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF5B5A56),
            fontSize: 20.h,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Padding(
          padding: EdgeInsets.only(right: 3.0.w),
          child: Container(
            height: 24.h,
            width: 24.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF2EBE3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF92918C),
              size: 16,
            ),
          ),
        ),
        onTap: () => onTap(),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }

  // 로그아웃 다이알로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.center,
          insetPadding: EdgeInsets.symmetric(
            horizontal: 26.w,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 340.w,
            height: 230.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(
                      fontSize: 16.h,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 106, 106, 106),
                    ),
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _loginPlatform = await loadLoginPlatform();
                        debugPrint(
                            'Current login platform: $_loginPlatform'); // Add this line
                        await SignOutService.signOut(
                            _loginPlatform); // 소셜로그인 로그아웃하기
                        // ignore: use_build_context_synchronously
                        sendLogoutRequest(context); // 앱 로그아웃하기
                        _resetUserProfile();
                      },
                      child: Container(
                        width: 263.w,
                        height: 46.h,
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
                        margin: EdgeInsets.only(top: 12.0.h),
                        width: 263.w,
                        height: 46.h,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
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
}
