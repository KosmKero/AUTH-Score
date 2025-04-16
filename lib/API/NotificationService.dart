import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


Future<void> initia() async {

  await Firebase.initializeApp();
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
    await _saveTokenToFirestore();
  }

  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔐 User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_notification');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📥 Foreground message: ${message.notification?.title}');

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
              styleInformation: BigTextStyleInformation(''),
            ),
          ),
        );
      }
    });
  }

  static void _listenToMessageTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Notification tapped (background): ${message.notification?.title}');
      // Μπορείς να κάνεις navigation εδώ π.χ.
    });
  }

  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print("🚪 Opened from terminated: ${initialMessage.notification?.title}");
      // Μπορείς να κάνεις navigation εδώ π.χ.
    }
  }

  static void _watchTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('♻️ Token refreshed: $newToken');
      _saveTokenToFirestore(newToken);
    });
  }

  static Future<void> _saveTokenToFirestore([String? newToken]) async {
    String? token = newToken ?? await _messaging.getToken();
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null && token != null) {
      DocumentReference userDoc =
      FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot docSnap = await userDoc.get();
      String? savedToken = docSnap.get('fcmToken');

      if (savedToken != token) {
        await userDoc.update({'fcmToken': token});
        print('💾 Token saved to Firestore.');
      } else {
        print('⚖️ Token is already up to date.');
      }
    }
  }
}
