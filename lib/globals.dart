library my_project.globals;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Data_Classes/AppUser.dart';
import 'Data_Classes/Team.dart';


bool isLoggedIn=false;
bool darkModeOn=false;
String username = "";
AppUser globalUser= AppUser("","",[],[]);


bool greek = true;
List<Team> teams = [];


Color darkModeBackGround = const Color.fromARGB(250, 64, 64, 64);
Color darkModeWidgets = Color.fromARGB(255, 80, 80, 80);
Color darkModeMatches = Color.fromARGB(255, 150, 150, 150);
Color darkModeText = Colors.white;




void updateUserChar(String username,String key) async
{
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('Username', isEqualTo: username)
      .limit(1)
      .get();

  if(querySnapshot.docs.isNotEmpty)
    {
      DocumentReference userDocRef = querySnapshot.docs.first.reference;
      if(key=="Language") {
        await userDocRef.update({key:greek});
      }
    }

}


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