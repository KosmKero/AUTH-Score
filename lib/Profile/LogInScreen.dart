import 'package:flutter/material.dart';
import '../Data_Classes/User.dart';


// Remove the global variables since we're moving them to the state class
bool secure = true;
List<String> allItems = ['Πληροφορική', 'Οικονομικό', 'Φυσικό', 'Νομική', 'Ψυχολογία', 'Μαθηματικό', 'Βιολογικό', 'Χημικό', 'Παμάκ'];
List<String> filteredItems = [];
TextEditingController searchController = TextEditingController();
bool showSuggestions = false;

class LogInScreen extends StatefulWidget {
  final User user;
  const LogInScreen({super.key, required this.user});

  @override
  State<LogInScreen> createState() => _LogInScreen();
}

class _LogInScreen extends State<LogInScreen> {
  // Move signIn state here
  bool signIn = true;

  // Add method to toggle sign in state
  void toggleSignIn() {
    setState(() {
      signIn = !signIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreateAppBar(signIn: signIn), // Pass signIn to AppBar
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
class CreateAppBar extends StatefulWidget implements PreferredSizeWidget {
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
      backgroundColor: Colors.lightBlueAccent,
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
      children: [
        Padding(
          padding: EdgeInsets.only(right: 30, top: 30),
          child: Text(
            "Sign in",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 50),
        Padding(
          padding: EdgeInsets.only(right: 250),
          child: Text(
            "Username",
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
        SizedBox(height: 40),
        Padding(
          padding: EdgeInsets.only(right: 250),
          child: Text(
            "Password",
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
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.only(right: 200),
          child: TextButton(
            onPressed: () {},
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueAccent
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        CreateButton(signIn: true),
        SizedBox(height: 60),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "If you don't have an account",
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
                    "Click here",
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
      children: [
        Padding(
          padding: EdgeInsets.only(right: 30, top: 10),
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 30),

        Padding(
          padding: EdgeInsets.only(right: 250),
          child: Text(
            "Username",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        SizedBox(height: 10),

        Padding(
          padding: EdgeInsets.only(left: 5, right: 30),
          child: TextField(
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
        SizedBox(height: 30),

        Padding(
          padding: EdgeInsets.only(right: 250),
          child: Text(
            "Password",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        SizedBox(height: 10),

        Padding(
          padding: EdgeInsets.only(left: 5, right: 30),
          child: TextField(
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
        SizedBox(height: 30),

        Padding(
          padding: EdgeInsets.only(right: 270),
          child:
          Text(
            "Σχολή",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        SizedBox(height: 20),

        Padding(
          padding: EdgeInsets.only(left: 10, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
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
        SizedBox(height: 70),

        CreateButton(signIn: false),

        SizedBox(height:25),

        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Already have an account?",
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
                    "Sign in",
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
  const CreateButton({super.key, required this.signIn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 25, right: 25, top: 50),
      child: Container(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 3,
          ),
          child: Text(
            signIn ? "SIGN IN" : "SIGN UP",
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