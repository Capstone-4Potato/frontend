import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/new/models/image_path.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  List<int> expandedIndexes = []; // 확장된 아이템의 인덱스를 저장

  @override
  void initState() {
    super.initState();
    fetchNotificationData();
  }

  Future<void> fetchNotificationData() async {
    try {
      var url = Uri.parse('$main_url/notification');
      String? token = await getAccessToken();

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

  // 생성 날짜 받아서 포맷 지정
  String formatTimestamp(String createdAt) {
    final now = DateTime.now();
    final notificationTime = DateTime.parse(createdAt);

    if (now.difference(notificationTime).inDays == 0) {
      // The notification was created today
      final difference = now.difference(notificationTime);
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return '${difference.inHours} hours ago';
      }
    } else {
      // The notification was created on a different day
      return DateFormat('yyyy.MM.dd').format(notificationTime);
    }
  }

  // POST 요청 함수
  Future<void> postNotificationRead(int id) async {
    var url = Uri.parse('$main_url/notification/$id');
    String? token = await getAccessToken();

    try {
      // 요청 헤더 설정
      Map<String, String> headers = {
        'access': token!,
        'Content-Type': 'application/json',
      };

      // POST 요청 보내기
      final response = await http.post(url, headers: headers);

      // 상태 코드 확인 및 응답 처리
      if (response.statusCode == 200) {
        // 성공: JSON 파싱 후 반환
        print("알림$id 읽음 처리 성공!");
      } else {
        // 실패: 에러 메시지 반환
        throw Exception(
            'Failed to send POST request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 또는 기타 예외 처리
      print("Error sending POST request: $e");
      rethrow;
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
                final allRead = notifications
                    .every((notification) => !notification['unread']);
                print(allRead);
                Navigator.pop(context, allRead);
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
                  EdgeInsets.symmetric(horizontal: 14.0.w, vertical: 13.0.h),
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: ((context, index) {
                  final notification = notifications[index];
                  final formattedTime =
                      formatTimestamp(notification['createdAt']);
                  final isExpanded = expandedIndexes.contains(index);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.0.h),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Bounce(
                        duration: const Duration(milliseconds: 100),
                        onPressed: () async {
                          if (notification['unread'] == true) {
                            // POST 알림 읽음 처리
                            await postNotificationRead(notification['id']);
                            setState(() {
                              notification['unread'] = false; // 읽음 처리
                            });
                          }
                          setState(() {
                            // 확장 축소 상태 변경
                            if (isExpanded) {
                              expandedIndexes.remove(index);
                              print(expandedIndexes);
                            } else {
                              expandedIndexes.add(index);
                              print(expandedIndexes);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15.0.h, horizontal: 12.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 12.w),
                                  child: CircleAvatar(
                                    radius: 21.r,
                                    backgroundColor: const Color(0xFFFFA069),
                                    child: SvgPicture.asset(
                                      'assets/image/noti_character.svg',
                                      width: 42.w,
                                      height: 42.h,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 120.w,
                                          child: Text(
                                            '${notification["title"]}',
                                            style: TextStyle(
                                              fontSize: 16.h,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: isExpanded ? null : 1,
                                            softWrap: true,
                                            overflow: isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 165.w,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: 4.w,
                                                height: 4.h,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFF5E5D58),
                                                ),
                                              ),
                                              SizedBox(width: 5.w),
                                              Text(
                                                formattedTime,
                                                style: TextStyle(
                                                  fontSize: 16.h,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      const Color(0xFF5E5D58),
                                                ),
                                              ),
                                              Container(
                                                width: 10.w,
                                                height: 10.h,
                                                margin: EdgeInsets.all(8.w),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: notification['unread']
                                                      ? primary
                                                      : Colors.transparent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 285.w,
                                      child: Text(
                                        '${notification["content"]}',
                                        style: TextStyle(
                                          color: const Color(0xFF5B5A56),
                                          fontSize: 16.h,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: isExpanded ? null : 3,
                                        softWrap: true,
                                        overflow: isExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
    );
  }
}
