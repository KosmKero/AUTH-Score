
import 'Team.dart';

class AppUser
{

  AppUser(this._username,this._password,this._university){
    _isAdmin=false;
  }
  String _username,_password,_university;
  bool _isLoggedIn=false;
  late bool _isAdmin;


  List<Team> favoriteList=[];
  final List<Team> _controlledTeams=[];


  String get username => _username;
  String get password => _password;
  String get university => _university;
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