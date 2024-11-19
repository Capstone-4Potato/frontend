import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotificationData();
  }

  Future<void> fetchNotificationData() async {
    try {
      var url = Uri.parse('$main_url/notification');
      String? token = await getAccessToken();
      print('$token');

      // api 요청 함수
      Future<http.Response> makeRequest(String token) {
        var headers = <String, String>{
          'access': token,
          'Content-Type': 'application/json',
        };
        return http.get(url, headers: headers);
      }

      var response = await makeRequest(token!);

      if (response.statusCode == 200) {
        setState(() {
          // JSON 데이터 파싱 후 변수에 저장
          notifications =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          print("Notifications fetched and stored successfully.");
        });
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh and retry the request
        print('Access token expired. Refreshing token...');

        // Refresh the token
        bool isRefreshed = await refreshAccessToken();

        if (isRefreshed) {
          // Retry request with new token
          print('Token refreshed successfully. Retrying request...');
          String? newToken = await getAccessToken();
          response = await http.get(url, headers: {
            'access': '$newToken',
            'Content-Type': 'application/json'
          });

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            setState(() {
              // JSON 데이터 파싱 후 변수에 저장
              notifications =
                  List<Map<String, dynamic>>.from(json.decode(response.body));
              print("Notifications fetched and stored successfully.");
            });
          } else {
            // Handle other response codes after retry if needed
            print(
                'Unhandled server response after retry: ${response.statusCode}');
            print(json.decode(response.body));
          }
        } else {
          print('Failed to refresh token. Please log in again.');
        }
      } else {
        // Handle other status codes
        print('Unhandled server response: ${response.statusCode}');

        print(json.decode(response.body));
      }
    } catch (e) {
      // Handle network request exceptions
      print("Error during the request: $e");
    }
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
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: const Text(
          'Noticfications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: primary,
      ),
      body: notifications.isEmpty
          ? Center(
              child: CircularProgressIndicator(
              color: primary,
            ))
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: ((context, index) {
                  final notification = notifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      title: Text(
                        '${notification["title"]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        '${notification["content"]}',
                        style: const TextStyle(
                          color: Color(0xFF5B5A56),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      leading: CircleAvatar(
                        radius: 21,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 160, 105),
                        child: Image.asset('assets/image/noti_character.png'),
                      ),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16) //모서리,
                          ),
                    ),
                  );
                }),
              ),
            ),
    );
  }
}
