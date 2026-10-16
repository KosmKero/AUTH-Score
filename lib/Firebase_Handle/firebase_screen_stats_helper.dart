import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:ui';

// 1. Σύνδεση User ID (Το καλείς μία φορά στο Login ή στο Splash Screen)
Future<void> setAnalyticsUser(String uid) async {
  await FirebaseAnalytics.instance.setUserId(id: uid);
}

// 2. Αναβαθμισμένο Screen Tracking (Δέχεται προαιρετικά matchId και έξτρα data)
Future<void> logScreenViewSta({
  required String screenName,
  required String screenClass,
  String? matchId,
  Map<String, Object>? extraParameters,
}) async {
  final Map<String, Object> params = {
    'screenStatsCustom': screenName,
    'screenStatsCustomClass': screenClass,
  };

  // Αν η οθόνη αφορά αγώνα, προσθέτουμε το match_id για το Funnel
  if (matchId != null) {
    params['match_id'] = matchId;
  }

  // Προσθήκη τυχόν έξτρα παραμέτρων
  if (extraParameters != null) {
    params.addAll(extraParameters);
  }

  await FirebaseAnalytics.instance.logEvent(
    name: 'Mycustom_screen_stats',
    parameters: params,
  );
}

void setUserLocaleProperty() async {
  final locale = PlatformDispatcher.instance.locale;

  await FirebaseAnalytics.instance.setUserProperty(
    name: 'device_locale',
    value: '${locale.languageCode}_${locale.countryCode}', // π.χ. el_GR
  );
}