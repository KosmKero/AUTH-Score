import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Data_Classes/MatchDetails.dart';
import '../Match_Details_Package/Match_Details_Page.dart';
import '../globals.dart';
import '../main.dart';

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('🌙 Notification in Background: ${message.notification?.title}');
}

Future<void> initia() async {
  // Δεν χρειάζεται ξανά το Firebase.initializeApp αν υπάρχει στο main.dart
  await NotificationService.init();
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _handleInitialMessage();

    _listenToForegroundMessages();
    _listenToMessageTap();
    _watchTokenRefresh();

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    await _saveTokenToFirestore();
  }

  static Future<void> _requestPermission() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
     print("⚠️ Η αίτηση για άδεια ειδοποιήσεων εκκρεμεί ήδη: $e");
    }
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_notification');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !Platform.isIOS) {
        _flutterLocalNotificationsPlugin.show(
          0,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'Ειδοποιήσεις',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@drawable/ic_notification',
              styleInformation: BigTextStyleInformation(notification.body ?? ''),
            ),
          ),
        );
      }
    });
  }

  static void _listenToMessageTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });
  }

  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationClick(initialMessage);
      });
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    if (message.data.containsKey('matchId')) {
      String matchId = message.data['matchId'];
      if (upcomingMatches.isEmpty && previousMatches.isEmpty) {
        pendingMatchId = matchId;
      } else {
        navigateToMatch(matchId);
      }
    }
  }

  static void navigateToMatch(String matchId) {
    if (navigatorKey.currentState != null) {
      MatchDetails? targetMatch;
      try {
        targetMatch = upcomingMatches.firstWhere((m) => m.matchDocId == matchId);
      } catch (e) {
        try {
          targetMatch = previousMatches.firstWhere((m) => m.matchDocId == matchId);
        } catch (e) {}
      }

      if (targetMatch != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => matchDetailsPage(targetMatch!)),
        );
      }
    }
  }

  static void _watchTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      _saveTokenToFirestore(newToken);
    });
  }

  static Future<void> _saveTokenToFirestore([String? newToken]) async {
    String? token = newToken;

    if (token == null) {
      try {
        token = await _messaging.getToken();
      } catch (e) {
        print("⚠️ FCM Token Error: $e");
        return;
      }
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && token != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot docSnap = await userDoc.get();

      String? savedToken;
      try {
        final data = docSnap.data() as Map<String, dynamic>?;
        savedToken = data?['fcmToken'];
      } catch (e) {
        savedToken = null;
      }

      if (savedToken != token) {
        await userDoc.set({'fcmToken': token}, SetOptions(merge: true));
        print('💾 Token updated in Firestore.');
      }
    }
  }
}