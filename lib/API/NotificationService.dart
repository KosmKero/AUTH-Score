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
      _handleNotificationClick(message); // Προσθήκη
    });
  }

  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print("🚪 Opened from terminated: ${initialMessage.notification?.title}");

      // Βάζουμε ένα μικρό delay για να προλάβει να φορτώσει το αρχικό UI (MaterialApp)
      Future.delayed(Duration(milliseconds: 500), () {
        _handleNotificationClick(initialMessage); // Προσθήκη
      });
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    if (message.data.containsKey('matchId')) {
      String matchId = message.data['matchId'];
      print("🎯 Πάτησες την ειδοποίηση για το ματς με ID: $matchId");

      // Αν οι λίστες είναι άδειες (το app μόλις άνοιξε), το κρατάμε για μετά!
      if (upcomingMatches.isEmpty && previousMatches.isEmpty) {
        print("⏳ Τα δεδομένα φορτώνουν ακόμα. Αποθήκευση ID για αργότερα...");
        pendingMatchId = matchId;
      } else {
        // Αν το app ήταν στο background και τα ματς είναι ήδη φορτωμένα
        navigateToMatch(matchId);
      }
    }
  }

  // Νέα βοηθητική συνάρτηση που κάνει την πλοήγηση
  static void navigateToMatch(String matchId) {
    if (navigatorKey.currentState != null) {
      MatchDetails? targetMatch;

      try {
        targetMatch = upcomingMatches.firstWhere((m) => m.matchDocId == matchId);
      } catch (e) {}

      if (targetMatch == null) {
        try {
          targetMatch = previousMatches.firstWhere((m) => m.matchDocId == matchId);
        } catch (e) {}
      }

      if (targetMatch == null) {
        try {
          targetMatch = playOffMatches.values.firstWhere((m) => m.matchDocId == matchId);
        } catch (e) {}
      }

      if (targetMatch != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => matchDetailsPage(targetMatch!),
          ),
        );
      } else {
        print("⚠️ Το ματς δεν βρέθηκε στις λίστες.");
      }
    }
  }

  static void _watchTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {

      _saveTokenToFirestore(newToken);
    });
  }

  static Future<void> _saveTokenToFirestore([String? newToken]) async {
    String? token = newToken ?? await _messaging.getToken();
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null && token != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot docSnap = await userDoc.get();

      String? savedToken;
      try {
        final data = docSnap.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('fcmToken')) {
          savedToken = data['fcmToken'];
        }
      } catch (e) {
        savedToken = null;
      }

      if (savedToken != token) {
        await userDoc.set({'fcmToken': token}, SetOptions(merge: true));
        print('💾 Token saved to Firestore successfully.');
      } else {
        print('⚖️ Token is already up to date.');
      }
    }
  }
}




