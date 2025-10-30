library my_project.globals;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';
import 'Data_Classes/AppUser.dart';
import 'Data_Classes/Team.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool isLoggedIn=false;
ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);
bool greek = true;
String username = "";
AppUser globalUser= AppUser("","",[],[],"user",{},"");
bool isToggled = false;

List<Team> topTeams = [];


List<Team> teams = [];

int thisYearNow=2026;

Map<int, MatchDetails> playOffMatches = {};

// 🌞 Light Mode
Color lightModeBackGround = const Color(0xFF97B4C3);   // απαλή μπλε-γκρι βάση
Color lightModeContainer = const Color(0xFFF7F7F7);    // σχεδόν λευκό για κάρτες/κουτιά
Color lightModeText = const Color(0xFF14131D);         // σκούρο για καθαρή αντίθεση

// 🌙 Dark Mode
Color darkModeBackGround = const Color(0xFF1E1E1E);    // πιο βαθύ γκρι/μαύρο
Color darkModeWidgets = const Color(0xFF2C2C2C);       // γκρι για κουτιά
Color darkModeMatches = const Color(0xFF2C2C2C);       // ίδιο για ομοιομορφία
Color darkModeText = const Color(0xFFB0BEC5);          // απαλό γκρι-γαλάζιο (blueGrey 200 περίπου)





Future<bool> getValue(String username, String key) async
{
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('Username', isEqualTo: username)
      .limit(1)
      .get();

  if(querySnapshot.docs.isNotEmpty)
    {
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      return userDoc[key];
    }

  return true;
}