import 'package:untitled1/main.dart';

import '../Data_Classes/Team.dart';
import '../Data_Classes/AppUser.dart';


class UserHandle{


  static List<AppUser> userList=[];

  // Μέθοδος για επιστροφή του ίδιου instance
  UserHandle() {
    _user?.makeAdmin(teams.first);
    _user?.addControlledTeam(teams[2]);
    _user?.addControlledTeam(teams[4]);
  }

  AppUser? _user;

  void initializeUsers(List<AppUser> list){
    userList=list;
  }



  int signUp(String name, String lastName, String username, String password,String uni) {
    if (name.isEmpty || lastName.isEmpty || username.isEmpty || password.isEmpty || uni.isEmpty) {
      return 2; // Ένα κενο πεδίο
    }
    for (AppUser user in userList) {
      if (user.username==username) {
        return 0;   // το username υπάρχει ήδη
      }
    }
    AppUser user=AppUser(username, password,uni);
    userList.add(user);
    login(username, password);
    return 1;  // το sign up γίνεται σωστά
  }


  bool login(String username, String password) {
    for (AppUser users in userList) {
      if (users.username == username && users.password==password) {
        _user = users;
        _user?.userLoggedIn();
        return true;
      }
    }
    return false;
  }

  AppUser? getLoggedUser(){
    return _user;
  }


}