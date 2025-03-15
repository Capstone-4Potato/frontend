import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsWrapper extends StatelessWidget {
  final Widget child;
  final String eventName;
  final Map<String, dynamic> parameters;

  const AnalyticsWrapper({
    Key? key,
    required this.child,
    required this.eventName,
    this.parameters = const {},
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FirebaseAnalytics.instance.logEvent(
          name: eventName,
          parameters:
              parameters.map((key, value) => MapEntry(key, value as Object)),
        );
        debugPrint('📊 Analytics: Event - $eventName, Params: $parameters');
      },
      child: child,
    );
  }
}
