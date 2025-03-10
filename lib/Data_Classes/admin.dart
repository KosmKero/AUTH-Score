import 'Team.dart';

class Admin{

  Admin(this._username,this._password);
  String _username,_password;
  bool _isLoggedIn=false;

  final List<Team> _favoriteList=[];
  final List<Team> _controlledTeams=[];

  String get username => _username;
  String get password => _password;
  bool get isLoggedIn => _isLoggedIn;
  List<Team> get favoriteList => _favoriteList;
  List<Team> get controlledTeams=> _controlledTeams;




  void addFavoriteTeam(Team team){
    _favoriteList.add(team);
  }
  void addControlledTeam(Team team){
    _controlledTeams.add(team);
  }

  void changeLogIn(){
    _isLoggedIn=!_isLoggedIn;
  }

  List<Team> getFavoriteTeamList(){
    return favoriteList;
  }

}