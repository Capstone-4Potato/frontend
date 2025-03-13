import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/new/services/user_id_manage.dart';

class FirestoreListener {
  /// 알림 권한 요청 세팅
  Future<void> setupPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 알림 권한 요청 (iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('푸시 알림 권한이 허용됨');
    } else {
      debugPrint('푸시 알림 권한이 거부됨');
    }

    // 앱이 포그라운드에 있을 때 (알림이 화면에 뜨지는 않음)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        debugPrint(
            "푸시 알림 도착: ${message.notification!.title}, ${message.notification!.body}");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("알림 클릭 후 앱이 열림: ${message.notification!.title}");
    });
  }

  Future<void> saveDeviceToken() async {
    // FCM 토큰 가져오기
    String? token = await FirebaseMessaging.instance.getToken();
    String? userId = await getUserId();

    if (token != null) {
      // Firestore 인스턴스
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 기기 토큰 저장할 컬렉션
      CollectionReference tokensCollection =
          firestore.collection('device_tokens');

      // 토큰을 Firestore에 저장
      await tokensCollection
          .doc(userId)
          .set({'token': token, 'userId': userId});
      debugPrint("✅ 기기 토큰 저장 성공: $token");
    } else {
      debugPrint("❌ 기기 토큰을 가져오는 데 실패했습니다.");
    }
  }
}
