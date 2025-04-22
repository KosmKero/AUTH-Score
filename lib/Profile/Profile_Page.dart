import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Profile/ChangePassword.dart';
import 'package:untitled1/Profile/ChangeUserName.dart';
import 'package:untitled1/Profile/admin/update_betting_results_button.dart';
import 'package:untitled1/Profile/admin_request_screen.dart';
import 'package:untitled1/Profile/feedback_page.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/AppUser.dart';
import '../Firebase_Handle/betting_result_update.dart';
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

  late Future<bool> _isSuperAdminFuture;
  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _isSuperAdminFuture = globalUser.isSuperUser();
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
          backgroundColor: darkModeOn ? Color(0xFF121212) : lightModeBackGround,
          body: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                      color: darkModeOn ? Color(0xFF1E1E1E) : Colors.blue[50],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: darkModeOn
                              ? Colors.black.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      greek ? "Επεξεργασία Προφίλ" : "Edit profile",
                      style: TextStyle(
                        fontSize: greek ? 24 : 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Arial',
                        fontStyle: FontStyle.italic,
                        color: darkModeOn ? Colors.white : Colors.blue[900],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: darkModeOn ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: darkModeOn
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.leaderboard_rounded,
                        color: darkModeOn ? Colors.white : Colors.blue,
                      ),
                      title: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TopUsersList()),
                            );
                          },
                          child: Text(
                            "Top 20 Tipsters",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: darkModeOn ? Colors.white : Colors.black,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: darkModeOn ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: darkModeOn
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (isLoggedIn) ...[
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.person,
                              color: darkModeOn ? Colors.white : Colors.blue,
                            ),
                            title: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeUserName(user: widget.user)),
                                );
                              },
                              child: Text(
                                greek
                                    ? "Αλλαγή ονόματος χρήστη"
                                    : "Change username",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: darkModeOn
                                      ? Colors.white
                                      : Colors.blue[900],
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.lock,
                              color: darkModeOn ? Colors.white : Colors.blue,
                            ),
                            title: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChangePassword(user: widget.user)),
                                );
                              },
                              child: Text(
                                greek
                                    ? "Αλλαγή κωδικού σύνδεσης"
                                    : "Change password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: darkModeOn
                                      ? Colors.white
                                      : Colors.blue[900],
                                ),
                              ),
                            ),
                          ),
                        ],
                        ListTile(
                          dense: true,
                          leading: Icon(
                            isLoggedIn ? Icons.logout : Icons.login,
                            color: darkModeOn ? Colors.white : Colors.blue,
                          ),
                          title: TextButton(
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
                                  globalUser =
                                      AppUser(" ", " ", [], [], "user", {});
                                  signOutUser();
                                }
                              });
                            },
                            child: Text(
                              isLoggedIn
                                  ? greek
                                      ? "Αποσύνδεση"
                                      : "Disconnect"
                                  : greek
                                      ? "Σύνδεση/\nΔημιουργία Λογαριασμού"
                                      : "Login/Create an account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isLoggedIn
                                    ? Colors.red
                                    : darkModeOn
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        if (isLoggedIn)
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.admin_panel_settings,
                              color: darkModeOn ? Colors.white : Colors.blue,
                            ),
                            title: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AdminRequestScreen()),
                                );
                              },
                              child: Text(
                                greek
                                    ? "Άιτημα διαχείρισης ομάδας"
                                    : "Team management request",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: darkModeOn
                                      ? Colors.white
                                      : Colors.blue[900],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: LogInButton(
                      user: widget.user,
                      onLoginStateChanged: () {
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: darkModeOn ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: darkModeOn
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.language,
                                  color:
                                      darkModeOn ? Colors.white : Colors.blue,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  greek ? "Επιλογή Γλώσσας" : "Choose Language",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: darkModeOn
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: darkModeOn
                                    ? Colors.grey[850]
                                    : Colors.white,
                                value: greek ? "Ελληνικά" : "English",
                                icon: Icon(Icons.arrow_drop_down,
                                    color: darkModeOn
                                        ? Colors.white
                                        : Colors.black87),
                                style: TextStyle(
                                  color: darkModeOn
                                      ? Colors.white
                                      : Colors.black87,
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
                        Divider(
                            color: darkModeOn
                                ? Colors.grey[700]
                                : Colors.grey[300]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  darkModeOn
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color:
                                      darkModeOn ? Colors.white : Colors.blue,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  greek ? "Σκοτεινή λειτουργία" : "Dark mode",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: darkModeOn
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            OvalToggleButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: darkModeOn ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: darkModeOn
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.contact_support,
                              color: darkModeOn ? Colors.white : Colors.blue,
                            ),
                            SizedBox(width: 10),
                            Text(
                              greek
                                  ? "Επικοινωνία για προβλήματα"
                                  : "Communication for problems",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color:
                                    darkModeOn ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: darkModeOn
                                  ? Colors.white70
                                  : Colors.blue[700],
                            ),
                            SizedBox(width: 10),
                            Text(
                              "authscore@gmail.com",
                              style: TextStyle(
                                color: darkModeOn
                                    ? Colors.white70
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                            ),

                          ],
                        ),
                        SizedBox(height: 5,),
                        Divider(),
                        Row(
                          children: [
                            Icon(Icons.messenger,color: Colors.blue,),
                            TextButton(
                              onPressed: () {
                                if (isLoggedIn) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => FeedbackPage()),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                //backgroundColor: darkModeOn ? Colors.white10 : Colors.grey.shade200,
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),

                              ),
                              child: Text(
                                "Send feedback",
                                style: TextStyle(
                                  color: darkModeOn ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )

                          ],
                        ),
                        //SizedBox(height: 15),

                        /*Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: darkModeOn ? Colors.white70 : Colors.blue[700],
                            ),
                            SizedBox(width: 10),
                            Text(
                              "kosma pes email",
                              style: TextStyle(
                                color: darkModeOn ? Colors.white70 : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                         */
                      ],
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: _isSuperAdminFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Ή SizedBox.shrink() αν θες να μη φαίνεται τίποτα
                      }
                      if (snapshot.hasData &&
                          snapshot.data! &&
                          globalUser.isAdmin &&
                          globalUser.isLoggedIn) {
                        return Container(
                          margin: EdgeInsets.all(20),
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                darkModeOn ? Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: darkModeOn
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.admin_panel_settings,
                                  color:
                                      darkModeOn ? Colors.white : Colors.blue,
                                ),
                                title: TextButton(
                                  onPressed: () async {
                                    if (await _isSuperAdminFuture) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RequestApprovalScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    greek ? "Διαχειριστές" : "Admins handle",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: darkModeOn
                                          ? Colors.white
                                          : Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.admin_panel_settings,
                                  color:
                                      darkModeOn ? Colors.white : Colors.blue,
                                ),
                                title: TextButton(
                                  onPressed: () async {
                                    if (await _isSuperAdminFuture) {
                                      BettingResultUpdate()
                                          .checkAndUpdateStats();
                                    }
                                  },
                                  child: Text(
                                    greek
                                        ? "Ανανέωση στοιχημάτων"
                                        : "Betting update",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: darkModeOn
                                          ? Colors.white
                                          : Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  )
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
          padding: EdgeInsets.only(bottom: widget.user.isLoggedIn ? 30 : 50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
          )),
    ]);
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
                  ? Color(0xFF1E1E1E)
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
                        ? Color(0xFF2196F3)
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
