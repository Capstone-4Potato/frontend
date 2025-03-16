import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/home_nav.dart';

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
      final args = route.settings.arguments as Map;
      return args['screen_name'];
    } else {
      // Get the actual widget class name
      if (route is MaterialPageRoute) {
        try {
          // Build the widget
          Widget widget = route.buildContent(route.navigator!.context);

          // Get the runtime type as string
          String widgetType = widget.runtimeType.toString();

          // Special case for HomeNav
          if (widgetType == 'HomeNav') {
            // Try to access the bottomNavIndex property
            if (widget is HomeNav) {
              int bottomNavIndex = (widget as dynamic).bottomNavIndex ?? 0;
              if (bottomNavIndex == 0) {
                return 'HomeScreen';
              } else if (bottomNavIndex == 1) {
                return 'ReportScreen';
              }
            }
          }

          // Return the widget class name
          return widgetType;
        } catch (e) {
          debugPrint('📊 Analytics: Error getting screen name - $e');
          return null;
        }
      }
      return null;
    }
  }
}
