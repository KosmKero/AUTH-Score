import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Profile/ChangePassword.dart';
import 'package:untitled1/Profile/ChangeUserName.dart';
import 'package:untitled1/Profile/admin/update_betting_results_button.dart';
import 'package:untitled1/Profile/admin_request_screen.dart';
import 'package:untitled1/Profile/requests_and_admins_package/requests_and_admins_page.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/AppUser.dart';
import 'LogInScreen.dart';
import 'admin/requests_and_admins_page.dart';
import 'best_betters.dart';

Future<void> signOutUser() async {
  await FirebaseAuth.instance.signOut();
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});
  final AppUser user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isGreek = true;
  bool isLoading = true;
  String selectedLanguage = "";
  UserHandleBase userHandleBase = UserHandleBase();

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    if (isLoggedIn) {
      String lang =
          await UserHandleBase().getSelectedLanguage(globalUser.username);
      setState(() {
        isGreek = (lang == "Ελληνικά");
        selectedLanguage = lang;
        greek = isGreek;
        isLoading = false;
      });
    } else {
      setState(() {
        isGreek = true;
        greek = true;
        selectedLanguage = "Ελληνικά";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, darkModeOn, _) {
        return Scaffold(
          backgroundColor: darkModeOn ? darkModeBackGround : lightModeBackGround,
          body: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Kane me admin tou thryloy",
                          style: TextStyle(
                            color: darkModeOn ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RequestApprovalScreen()),
                          );
                        },
                        child: Text("see Requests",
                            style: TextStyle(
                                color: darkModeOn
                                    ? Colors.white
                                    : Colors.black87)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminRequestScreen()),
                          );
                        },
                        child: Text("req",
                            style: TextStyle(
                                color: darkModeOn
                                    ? Colors.white
                                    : Colors.black87)),
                      ),
                    ],
                  ),
                  AdminPanel(),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TopUsersListPage()),
                        );
                      },
                      child: Text("data")),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, top: 15, left: 5),
                    child: Text(
                      greek ? "Επεξεργασία Προφίλ" : "Edit profile",
                      style: TextStyle(
                        fontSize: greek ? 21 : 23,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Trajan Pro',
                        fontStyle: FontStyle.italic,
                        color: darkModeOn ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 130),
                    child: Image.asset(
                      "fotos/user.jpg",
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isLoggedIn)
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 1, top: 5, right: greek ? 170 : 220),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChangeUserName(user: widget.user)),
                          );
                        },
                        child: Text(
                          greek ? "Αλλαγή ονόματος χρήστη" : "Change username",
                          style: TextStyle(
                            fontSize: greek ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: darkModeOn
                                ? Colors.white
                                : Color.fromARGB(255, 70, 107, 255),
                          ),
                        ),
                      ),
                    ),
                  if (isLoggedIn)
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 25, top: 1, right: greek ? 170 : 220),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChangePassword(user: widget.user)),
                          );
                        },
                        child: Text(
                          greek ? "Αλλαγή κωδικού σύνδεσης" : "Change password",
                          style: TextStyle(
                            fontSize: greek ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: darkModeOn
                                ? Colors.white
                                : Color.fromARGB(255, 70, 107, 255),
                          ),
                        ),
                      ),
                    ),
                  LogInButton(
                    user: widget.user,
                    onLoginStateChanged: () {
                      setState(() {}); // Refresh ProfilePage
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 50),
                          child: Text(
                            greek ? "Επιλογή Γλώσσας" : "Choose Language",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkModeOn ? Colors.white : Colors.white,
                            ),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor:
                                darkModeOn ? Colors.grey[850] : Colors.white,
                            value: greek ? "Ελληνικά" : "English",
                            icon: Icon(Icons.language,
                                color:
                                    darkModeOn ? Colors.white : Colors.black87),
                            style: TextStyle(
                              color: darkModeOn ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  selectedLanguage = newValue;
                                  greek = (newValue == "Ελληνικά");
                                });
                                if (isLoggedIn) {
                                  await userHandleBase.updateLanguageChoice(
                                      globalUser.username, newValue);
                                }
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: "Ελληνικά",
                                child: Row(
                                  children: const [
                                    Icon(Icons.flag, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text("Ελληνικά"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "English",
                                child: Row(
                                  children: const [
                                    Icon(Icons.flag, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text("English"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(left: 21, bottom: 30),
                    child: Row(
                      children: [
                        Text(
                          greek ? "Σκοτεινή λειτουργία" : "Dark mode",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: darkModeOn ? Colors.white : Colors.white,
                          ),
                        ),
                        SizedBox(width: 25),
                        OvalToggleButton(),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greek
                              ? "Επικοινωνία για προβλήματα"
                              : "Communication for problems",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: Text(
                            "Email: adamo@csd.auth.gr",
                            style: TextStyle(
                                color:
                                    darkModeOn ? Colors.white : Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.only(right: 45),
                          child: Text(
                            "Email: kosma pes email",
                            style: TextStyle(
                                color:
                                    darkModeOn ? Colors.white : Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}



// LOGIN BUTTON THAT TRIGGERS PAGE REFRESH
class LogInButton extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLoginStateChanged; // Callback to refresh the page

  const LogInButton(
      {super.key, required this.user, required this.onLoginStateChanged});

  @override
  State<LogInButton> createState() => _LogInButtonState();
}

class _LogInButtonState extends State<LogInButton> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(bottom: widget.user.isLoggedIn ? 70 : 70),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    isLoggedIn ? Colors.red : Colors.blue),
              ),
              onPressed: () {
                setState(() {
                  if (!isLoggedIn) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LogInScreen(user: widget.user)));
                  } else {
                    isLoggedIn = false;
                    globalUser = AppUser(" ", " ", [], [], "user");
                    signOutUser();
                  }
                  //widget.user.changeLogIn(); // Toggle login state
                });
                widget.onLoginStateChanged(); // Notify ProfilePage to refresh
              },
              child: Text(
                isLoggedIn
                    ? greek
                        ? "Αποσύνδεση"
                        : "Disconnect"
                    : greek
                        ? "Σύνδεση/Δημιουργία Λογαριασμού"
                        : "Login/Create an account",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          )),
    ]);

    return Column(
        children:[
          Padding(
            padding: EdgeInsets.only(bottom: widget.user.isLoggedIn ? 70 : 70),
            child:
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child:
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                           isLoggedIn ? Colors.red : Color.fromARGB(250, 46, 90, 136)),
                      ),
                      onPressed: () {
                        setState(() {
                          if(!isLoggedIn) {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => LogInScreen(user: widget.user)));
                          }
                          else{
                            isLoggedIn=false;
                            globalUser=AppUser(" "," ",[ ], [],"user");
                            signOutUser();
                          }
                          //widget.user.changeLogIn(); // Toggle login state
                        });
                        widget.onLoginStateChanged(); // Notify ProfilePage to refresh
                      },
                      child: Text(
                        isLoggedIn ? greek?"Αποσύνδεση":"Disconnect" : greek?"Σύνδεση/Δημιουργία Λογαριασμού":"Login/Create an account",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                )
          ),
        ]
    );
  }
}

//ΔΗΔΗΜΙΟΥΡΓΕΙ ΤΟ ΚΥΚΛΙΚΟ ΚΟΥΜΠΙ!!
class OvalToggleButton extends StatefulWidget {
  @override
  _OvalToggleButtonState createState() => _OvalToggleButtonState();
}

class _OvalToggleButtonState extends State<OvalToggleButton> {
  UserHandleBase userHandleBase = UserHandleBase();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isToggled, _) {
        return GestureDetector(
          onTap: () {
            bool newValue = !isToggled;
            darkModeNotifier.value = newValue;

            if (isLoggedIn) {
              userHandleBase.changeDarkMode(globalUser.username);
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: isToggled
                  ? Colors.black87
                  : Color.fromARGB(255, 192, 192, 192),
              borderRadius: BorderRadius.circular(30),
            ),
            child: AnimatedAlign(
              duration: Duration(milliseconds: 300),
              alignment:
                  isToggled ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isToggled
                        ? Colors.black87
                        : Color.fromARGB(255, 192, 192, 192),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isToggled ? Icons.dark_mode : Icons.light_mode,
                    size: 20,
                    color: isToggled ? Colors.white : Colors.yellow,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
