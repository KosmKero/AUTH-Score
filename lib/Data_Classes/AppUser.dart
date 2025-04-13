
import 'package:untitled1/globals.dart';

import 'Team.dart';

class AppUser
{
  String _username,_university;
  bool _isLoggedIn=true;
  late bool _isAdmin;

  List<String> favoriteList=[];
  List<String> _controlledTeams=[];

  AppUser(this._username,this._university,this.favoriteList,this._controlledTeams){
    _isAdmin=true; //θελει αλλαγη
  }

  String get username => _username;
  String get university => _university;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin=> _isAdmin;
  List<String> get controlledTeams=> _controlledTeams;


  void addFavoriteTeam(Team team){
    favoriteList.add(team.name);
  }

  void changeLogIn(){
    _isLoggedIn=!_isLoggedIn;
  }
  void userLoggedIn(){
    _isLoggedIn=true;
  }

  List<String> getFavoriteTeamList(){
    return favoriteList;
  }


  void addControlledTeam(Team team){
    _controlledTeams.add(team.name);
  }

  void addControlledTeams(List<String> teamsName){
    _controlledTeams.addAll(teamsName);
  }

  void makeAdmin(Team team){
    _isAdmin=true;
    addControlledTeam(team);
  }

  void makeUser(){
    _isAdmin=false;
  }


  bool controlTheseTeams(String team1,String? team2) {
    if (!_isAdmin) return false;
    for (String name in controlledTeams){
      if (name==team1 ){
        return true;
      }
      else if (team2!=null){
       if (team2==name){
         return true;
       }
      }

    }
    return false;
  }



}