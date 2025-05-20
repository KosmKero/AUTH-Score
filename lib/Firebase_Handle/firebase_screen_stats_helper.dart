import 'package:firebase_analytics/firebase_analytics.dart';



Future<void> logScreenViewSta({
  required String screenName,
  required String screenClass,
}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'Mycustom_screen_stats',
    parameters: {
      'screenStatsCustom': screenName,
      'screenStatsCustomClass': screenClass,
    },
  );
}

