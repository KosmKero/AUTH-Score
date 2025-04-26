import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/Team.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/AppUser.dart';
import '../main.dart';


// Remove the global variables since we're moving them to the state class
bool secure = true;
List<String> allItems = [
  'Αγγλικής Γλώσσας και Φιλολογίας',
  'Αγροτικής Ανάπτυξης',
  'Αρχιτεκτόνων Μηχανικών',
  'Βιολογίας',
  'Γαλλικής Γλώσσας και Φιλολογίας',
  'Γεωλογίας',
  'Γεωπονίας',
  'Δημοσιογραφίας και ΜΜΕ',
  'Δημόσιας Διοίκησης',
  'Διοίκησης Επιχειρήσεων',
  'Εικαστικών και Εφαρμοσμένων Τεχνών',
  'Ηλεκτρολόγων Μηχανικών και Μηχανικών Υπολογιστών',
  'Ιατρικής',
  'Ιστορίας και Αρχαιολογίας',
  'Ιταλικής Γλώσσας και Φιλολογίας',
  'Κτηνιατρικής',
  'Μαθηματικού',
  'Μηχανικών Χωροταξίας και Ανάπτυξης',
  'Μηχανολόγων Μηχανικών',
  'Μουσικών Σπουδών',
  'Νομικής',
  'Νοσηλευτικής',
  'Ξένων Γλωσσών, Μετάφρασης και Διερμηνείας',
  'Οικονομικών Επιστημών',
  'Παιδαγωγικό Δημοτικής Εκπαίδευσης',
  'Παιδαγωγικό Ειδικής Αγωγής',
  'Παιδαγωγικό Νηπιαγωγών',
  'Πολιτικών Επιστημών',
  'Πολιτικών Μηχανικών',
  'Πολιτισμού και Δημιουργικών Μέσων',
  'Πληροφορικής',
  'Προγραμμάτων Σπουδών Πολιτισμού',
  'Προγραμμάτων Σπουδών Τουρισμού',
  'Στατιστικής και Αναλογιστικών-Χρηματοοικονομικών Μαθηματικών',
  'Σπουδών Νοτιοανατολικής Ευρώπης',
  'Σπουδών Σλαβικών Γλωσσών και Φιλολογιών',
  'Σχολή Θεολογίας',
  'Σχολή Καλών Τεχνών',
  'Τεχνολογίας Τροφίμων',
  'Φαρμακευτικής',
  'Φιλολογίας',
  'Φιλοσοφίας και Παιδαγωγικής',
  'Φυσικής',
  'Χημείας',
  'Ψυχολογίας'
];
List<String> filteredItems = [];
TextEditingController searchController = TextEditingController();
bool showSuggestions = false;

final TextEditingController _emailText = TextEditingController();
final TextEditingController _passwordText = TextEditingController();
final TextEditingController _usernameText = TextEditingController();

final TextEditingController _textController4 = TextEditingController();
final TextEditingController _textController5 = TextEditingController();


class LogInScreen extends StatefulWidget {
  final AppUser user;
  const LogInScreen({super.key, required this.user});

  @override
  State<LogInScreen> createState() => _LogInScreen();
}

class _LogInScreen extends State<LogInScreen> {
  // Move signIn state here
  bool signIn = true;

  AppUser get user => user;

  // Add method to toggle sign in state
  void toggleSignIn() {
    setState(() {
      signIn = !signIn;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreateAppBar(
          signIn: signIn,

      ), // Pass signIn to AppBar
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Pass the toggle function and signIn state to child widgets
              signIn ? CreateSignIn(toggleSignIn: toggleSignIn) : CreateSignUp(toggleSignIn: toggleSignIn),
            ],
          ),
        ),
      ),
    );
  }
}

//ΔΗΜΙΟΥΡΓΕΙ ΤΗΝ APPBAR
class CreateAppBar extends StatefulWidget implements PreferredSizeWidget
{
  // Add signIn parameter
  final bool signIn;
  const CreateAppBar({super.key, required this.signIn});

  @override
  State<CreateAppBar> createState() => _createAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _createAppBarState extends State<CreateAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(250, 46, 90, 136),
      iconTheme: IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

//ΔΗΜΙΟΥΡΓΕΙ ΤΗΝ ΣΕΛΙΔΑ ΓΙΑ ΤΟ SIGN IN
class CreateSignIn extends StatefulWidget {
  // Add the toggle function parameter
  final Function toggleSignIn;
  const CreateSignIn({super.key, required this.toggleSignIn});

  @override
  State<CreateSignIn> createState() => _CreateSignIn();
}

class _CreateSignIn extends State<CreateSignIn> {
  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 5, top: 10),
          child: Text(
            greek?"Σύνδεση":"Sign in",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: "Arial"
            ),
          ),
        ),
        SizedBox(height: 50),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            'Email',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),

        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.only(left: 5, right: 55),
          child: TextField(
            controller: _textController4,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black87, width: 3),
              ),
              hintText: 'Enter your email',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
        SizedBox(height: 40),

        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            greek?"Κωδικός πρόσβασης":"Password",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.only(left: 5, right: 55),
          child: TextField(
            controller: _textController5,
            obscureText: passwordVisible,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black87, width: 3),
              ),
              hintText: 'Enter your Password',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
        SizedBox(height: 7),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: TextButton(
            onPressed: () {

              UserHandleBase().resetPassword(context, _textController4.text);
            },
            child: Text(
              greek?"Ξέχασα τον κωδικό":"Forgot my password?",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueAccent
              ),
            ),
          ),
        ),
        SizedBox(height: 13),
        CreateButton(
          signIn: true,
          emailText: _textController4,
          passwordText: _textController5,
        ),
        SizedBox(height: 15),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                greek?"Δεν έχεις λογαριασμό;":"If you don't have an account:",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),
              ),
              TextButton(
                  onPressed: () {
                    // Use the function from parent widget
                    widget.toggleSignIn();
                  },
                  child: Text(
                    greek?"Πάτα εδώ":"Click here",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                    ),
                  )
              )
            ]
        )
      ],
    );
  }
}

//ΔΗΜΙΟΥΡΓΕΙ ΤΗΝ ΣΕΛΙΔΑ ΓΙΑ ΤΟ SIGN UP
class CreateSignUp extends StatefulWidget {
  // Add the toggle function parameter
  final Function toggleSignIn;
  const CreateSignUp({super.key, required this.toggleSignIn});
  static const sxoles = ["s1","s2","s3","s4"];

  @override
  State<CreateSignUp> createState() => _CreateSignUp();
}

class _CreateSignUp extends State<CreateSignUp> {
  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(
              greek?"Δημιουργία λογαριασμού":"Create an account",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
        ),
        SizedBox(height: 40),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            greek? "Email" : "Username",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        SizedBox(height: 10),

        //TEXTFIELD 1!!!
        Padding(
          padding: EdgeInsets.only(left: 5, right: 30),
          child: TextField(
            controller: _emailText,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black87, width: 3),
              ),
              hintText: 'Enter your email',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),

        SizedBox(height: 20),

        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            greek? "Όνομα χρήστη" : "Username",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),

        SizedBox(height: 10),

        //TEXTFIELD 1!!!
        Padding(
          padding: EdgeInsets.only(left: 5, right: 30),
          child: TextField(
            controller: _usernameText,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black87, width: 3),
              ),
              hintText: 'Enter your username',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(
            greek?"Κωδικός πρόσβασης":"Password",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        SizedBox(height: 10),

        //TEXTFIELD 2
        Padding(
          padding: EdgeInsets.only(left: 5, right: 30),
          child: TextField(
            controller: _passwordText,
            obscureText: passwordVisible,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
              suffixIcon: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black87, width: 3),
              ),
              hintText: 'Create password',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        Padding(
          padding: EdgeInsets.only(left: 5), // το έφερα λίγο πιο μέσα
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             Text(
                  greek ? "Σχολή" : "University",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
              ),
              SizedBox(width: 7),
             Text(
                  greek ? "(Προαιρετικό)" : "(Optional)",
                  style: TextStyle(
                    //fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),

            ],
          ),
        ),
        SizedBox(height: 10),

        Padding(
          padding: EdgeInsets.only(left: 5, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                //controller: _textController3,
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        filteredItems = [];
                        showSuggestions = false;
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.black87, width: 3),
                  ),
                  hintText: 'Αναζήτηση σχολής...',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      filteredItems = [];
                      showSuggestions = false;
                    } else {
                      // Filter items that start with the entered text
                      filteredItems = allItems
                          .where((item) => item.toLowerCase().startsWith(value.toLowerCase()))
                          .toList();

                      // If no exact matches found, then show items containing the text
                      if (filteredItems.isEmpty) {
                        filteredItems = allItems
                            .where((item) => item.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      }

                      showSuggestions = true;
                    }
                  });
                },
              ),

              //ΕΔΩ ΞΕΚΙΝΑΕΙ ΓΙΑ ΤΟ SEARCH ΤΗΣ ΣΧΟΛΗΣ!!!
              if (showSuggestions && filteredItems.isNotEmpty)
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final query = searchController.text.toLowerCase();

                      // Highlight the matching part
                      final matchStart = item.toLowerCase().indexOf(query);
                      final beforeMatch = item.substring(0, matchStart);
                      final match = item.substring(matchStart, matchStart + query.length);
                      final afterMatch = item.substring(matchStart + query.length);

                      return ListTile(
                        dense: true,
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: beforeMatch,
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: match,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: afterMatch,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            searchController.text = item;
                            showSuggestions = false;
                          });
                          // You can also save the selected school to a variable here
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 50),

        CreateButton(
          signIn: false,
          emailText: _emailText,
          passwordText: _passwordText,
          usernameText: _usernameText,
          sxolhText: searchController,
        ),

        SizedBox(height:15),

        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                greek?"Έχεις ήδη λογαριασμό?" :"Already have an account?",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),
              ),
              TextButton(
                  onPressed: () {
                    // Use the function from parent widget
                    widget.toggleSignIn();
                  },
                  child: Text(
                    greek?"Σύνδεση":"Sign in",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                    ),
                  )
              )
            ]
        )
      ],
    );
  }
}

//ΔΗΜΙΟΥΡΓΕΙ ΤΟ ΚΟΥΜΠΙ ΓΙΑ ΤΟ SIGN IN/ SIGN UP
class CreateButton extends StatelessWidget {
  final bool signIn;
  final TextEditingController emailText;
  final TextEditingController passwordText;
  final TextEditingController? sxolhText;
  final TextEditingController? usernameText;
  //final User user;
  const CreateButton({
    super.key,
    required this.signIn,
    required this.emailText,
    required this.passwordText,
    this.usernameText,
    this.sxolhText,
  });

  //ΔΗΜΙΟΥΡΓΕΙ ΤΟ ΚΟΥΜΠΙ ΠΟΥ ΘΑ ΠΑΤΗΣΕΙ ΑΝ ΘΕΛΕΙ ΝΑ ΚΑΝΕΙΟ SIGN IN Ή LOG IN
  @override
  Widget build(BuildContext context)
  {
    return Padding(
      padding: EdgeInsets.only(left: 25, right: 25),
      child: Container(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () //ΑΝΑΛΟΓΑ ΜΕ ΤΗΝ ΚΑΤΑΣΤΑΣΗ ΠΟΥ ΕΙΜΑΣΤΕ ΚΑΛΟΥΜΕ ΜΙΑ ΑΠΟ ΤΙΣ 2 ΣΥΝΑΡΤΗΣΕΙΣ
          {
            signIn ? checkBase(context,emailText,passwordText) : addInBase(context,emailText,passwordText,sxolhText,usernameText);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 3,
          ),
          child: Text(
            signIn ? greek?"Σύνδεση":"SIGN IN" : greek?"Εγγραφή":"SIGN UP",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}


void checkBase(BuildContext context,emailText,passwordText) async
{

  try
  {
    String username = emailText.text;
    String password = passwordText.text;

    /*print('Attempting login with:');
    print('Username: $username');
    print('Password: $text2');

     */

    bool loginSuccess = await UserHandleBase().login(username, password);
    if (loginSuccess) {

      print('✅ ton brhkameeee!'); //ΥΠΑΡΧΕΙ ΑΝΤΙΣΤΟΙΧΙΑ ΔΕΔΟΜΕΝΩΝ
      isLoggedIn = true;
      emailText.clear();
      passwordText.clear();


      //ΕΠΙΣΤΡΕΦΩ ΣΤΗΝ ΑΡΧΙΚΗ ΣΕΛΙΔΑ!!
      try
      {
        greek = await getValue(globalUser.username,"Language");
        navigatorKey.currentState?.pushReplacementNamed('/home');

      } catch (navError) {
        print('🚨 Navigation Error: $navError');
      }
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar( //ΕΜΦΑΝΙΖΩ ΜΗΝΥΜΑ ΛΑΘΟΥΣ ΑΝ ΕΧΕΙ ΚΑΠΟΙΟ ΠΕΔΙΟ ΚΕΝΟ
          content: Text('The username or the password is incorrect!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  catch (e)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar( //ΕΜΦΑΝΙΖΩ ΜΗΝΥΜΑ ΛΑΘΟΥΣ ΑΝ ΕΧΕΙ ΚΑΠΟΙΟ ΠΕΔΙΟ ΚΕΝΟ
        content: Text('Something went wrong!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}


void addInBase(BuildContext context,TextEditingController  emailText,TextEditingController  passwordText, sxolhText, usernameText) async
{
  //ΠΑΙΡΝΩ ΤΙΣ ΤΙΜΕΣ ΤΩΝ ΠΕΔΙΩΝ!!
  String email = emailText.text;
  String password = passwordText.text;
  String sxolh = sxolhText.text;
  String username = usernameText.text;




  if(email.isEmpty || password.isEmpty || username.isEmpty)
  {
    // Show SnackBar with error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar( //ΕΜΦΑΝΙΖΩ ΜΗΝΥΜΑ ΛΑΘΟΥΣ ΑΝ ΕΧΕΙ ΚΑΠΟΙΟ ΠΕΔΙΟ ΚΕΝΟ
        content: Text('Please fill in all fields'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }
  bool found = await UserHandleBase().signUpWithEmail(email,username,password,sxolh,context);
  if(!found)
  {
    //κενη για τωρα για να εμφανιζουμε σωστο μηνυμα λαθους ρε
  }
  else
  {
    //AppUser currentUser = AppUser(_email,_password,_sxolh);
    isLoggedIn = true; //ΑΛΛΑΖΩ ΚΑΤΑΣΤΑΣΗ ΧΡΗΣΤΗ

    //ΚΑΘΑΡΙΖΩ ΤΑ ΠΕΔΙΑ ΟΤΑΝ ΠΑΤΗΣΕΙ ΤΟ ΚΟΥΜΠΙ ΕΓΓΡΑΦΗΣ
    emailText.clear();
    passwordText.clear();
    sxolhText.clear();

    username = email;
    print("Data successfully added!");
    navigatorKey.currentState?.pushReplacementNamed('/home');

  }
}
