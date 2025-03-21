import 'dart:ffi';

import 'Team.dart';

class User{

  User(this._name,this._lastName,this._username,this._password){
    _isAdmin=false;
  }
  String _name,_lastName,_username,_password;
  bool _isLoggedIn=false;
  late bool _isAdmin;


  List<Team> favoriteList=[];
  final List<Team> _controlledTeams=[];



  String get name => _name;
  String get lastName => _lastName;
  String get username => _username;
  String get password => _password;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin=> _isAdmin;
  List<Team> get controlledTeams=> _controlledTeams;


  void addFavoriteTeam(Team team){
    favoriteList.add(team);
  }

  void changeLogIn(){
    _isLoggedIn=!_isLoggedIn;
  }
  void userLoggedIn(){
    _isLoggedIn=true;
  }

  List<Team> getFavoriteTeamList(){
    return favoriteList;
  }


  void addControlledTeam(Team team){
    _controlledTeams.add(team);
  }

  void addControlledTeams(List<Team> teams){
    _controlledTeams.addAll(teams);
  }

  void makeAdmin(Team team){
    _isAdmin=true;
    addControlledTeam(team);
  }

  void makeUser(){
    _isAdmin=false;
  }


  bool controlTheseTeams(String team1,String team2) {
    if (!_isAdmin) return false;
    for (Team team in controlledTeams){
      if (team.name==team1 || team.name==team2){
        return true;
      }
    }
    return false;
  }



}