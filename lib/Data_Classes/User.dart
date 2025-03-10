import 'Team.dart';

class User{

  User(this._name,this._lastName,this._username,this._password);
  String _name,_lastName,_username,_password;
  bool _isLoggedIn=false;

  List<Team> favoriteList=[];

  String get name => _name;
  String get lastName => _lastName;
  String get username => _username;
  String get password => _password;
  bool get isLoggedIn => _isLoggedIn;

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



}