import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/services/api/notification_api.dart';
import 'package:flutter_application_1/new/utils/time_stamp_formatter.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = []; // 알림을 Map 형태로 저장
  List<int> expandedIndexes = []; // 확장된 아이템의 인덱스를 저장

  @override
  void initState() {
    super.initState();
    // 알림 데이터 초기화
    fetchNotificationData();
  }

  /// 알림 데이터 받아옴
  Future<void> fetchNotificationData() async {
    // 알림 리스트 api 요청
    var notificationData = await getNotificationList();
    setState(() {
      notifications = notificationData;
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
              color: Colors.white,
              onPressed: () {
                final allRead = notifications
                    .every((notification) => !notification['unread']);
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
                      formatTimeStamp(notification['createdAt']);
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
                            } else {
                              expandedIndexes.add(index);
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
