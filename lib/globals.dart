library my_project.globals;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';
import 'Data_Classes/AppUser.dart';
import 'Data_Classes/Team.dart';


bool isLoggedIn=false;
ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);
bool greek = true;
String username = "";
AppUser globalUser= AppUser("","",[],[],"user");
bool isToggled = false;

List<Team> topTeams = [];


List<Team> teams = [];

Map<int, MatchDetails> playOffMatches = {};


Color lightModeBackGround =Color.fromARGB(255, 151, 180, 195);    //Color.fromARGB(255, 125, 163, 181);
Color lightModeContainer = Color.fromARGB(255, 245, 245, 245);
Color lightModeText = Color.fromARGB(255, 20, 13, 29);

Color darkModeBackGround = Color.fromARGB(250, 50, 50, 50);
Color? darkModeWidgets = Colors.grey[800];
Color? darkModeMatches =  Colors.grey[800];
Color darkModeText = Colors.blueGrey;




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