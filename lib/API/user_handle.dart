import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled1/main.dart';

import '../Data_Classes/Team.dart';
import '../Data_Classes/AppUser.dart';
import '../globals.dart';

class UserHandle {
  static List<AppUser> userList = [];

  // Μέθοδος για επιστροφή του ίδιου instance
  UserHandle() {
    _user?.makeAdmin(teams.first);
    _user?.addControlledTeam(teams[2]);
    _user?.addControlledTeam(teams[4]);
  }

  AppUser? _user;

  void initializeUsers(List<AppUser> list) {
    userList = list;
  }


  // AppUser? getLoggedUser() {
  //   return _user;
  // }
}
