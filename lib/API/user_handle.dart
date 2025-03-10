import '../Data_Classes/User.dart';

class UserHandle{


  static List<User> userList=[];

  // Μέθοδος για επιστροφή του ίδιου instance
  UserHandle() {

  }

  User? user;

  void initializeUsers(List<User> list){
    userList=list;
  }



  int signUp(String name, String lastName, String username, String password) {
    if (name.isEmpty || lastName.isEmpty || username.isEmpty || password.isEmpty) {
      return 2; // Ένα κενο πεδίο
    }
    for (User user in userList) {
      if (user.username==username) {
        return 0;   // το username υπάρχει ήδη
      }
    }
    User user=User(name, lastName, username, password);
    userList.add(user);
    login(username, password);
    return 1;  // το sign up γίνεται σωστά
  }


  bool login(String username, String password) {
    for (User users in userList) {
      if (users.username == username && users.password==password) {
        user = users;
        user?.userLoggedIn();
        return true;
      }
    }
    return false;
  }




}