import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

/// GA 화면 전환 옵저버
class AnalyticsNavigatorObserver extends NavigatorObserver {
  final FirebaseAnalytics analytics;

  AnalyticsNavigatorObserver({required this.analytics});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _sendScreenView(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _sendScreenView(previousRoute);
  }

  /// GA에 화면 전환 로그 출력
  void _sendScreenView(Route<dynamic> route) {
    String? screenName = _getScreenName(route);
    if (screenName != null) {
      analytics.logScreenView(screenName: screenName);
      debugPrint('📊 Analytics: Screen view - $screenName');
    }
  }

  /// 화면 이름 받기
  String? _getScreenName(Route<dynamic> route) {
    if (route.settings.name != null) {
      return route.settings.name;
    } else if (route.settings.arguments is Map) {
      // arguments에서 screen_name을 추출할 수도 있습니다
      final args = route.settings.arguments as Map;
      return args['screen_name'];
    } else {
      // 라우트 이름이 없는 경우 위젯 타입을 사용
      if (route is MaterialPageRoute) {
        // 빌더의 타입에서 클래스 이름만 추출
        String fullType = route.builder.runtimeType.toString();

        // (BuildContext) => NotificationScreen 형태에서 NotificationScreen만 추출
        if (fullType.contains('=>')) {
          String className = fullType.split('=>').last.trim();
          return className;
        }
        return fullType;
      }
      return null;
    }
  }
}
