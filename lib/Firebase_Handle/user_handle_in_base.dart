import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';

import '../Data_Classes/AppUser.dart';
import '../globals.dart';

class UserHandleBase
{

  User? user;


  final FirebaseAuth database = FirebaseAuth.instance; // Αναφορά στη βάση


  //Επιστρέφει true αν συνδεθει και false αν το username υπάρχει ήδη ή συναντήσει πρόβλημα
  Future<bool> signUpWithEmail(String email,String username, String password,String uni,BuildContext context) async
  {

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(greek
              ? "Παρακαλώ δώστε ένα έγκυρο email."
              : "Please enter a valid email."),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }


    if (await isUsernameAvailable(username))
    {
      try {

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        user = userCredential.user;
        if (user != null) {
          // Αποθήκευση username στο Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .set({
            'username': username,
            'email': email,
            "University": uni,
            "Favourite Teams":[],
            "Controlled Teams":[],
            "darkMode":false,
            "Language":true,
            'role': 'user',
            "fcmToken": " ",
            'matchKeys': {}
          });


          globalUser = AppUser(username, uni, [], [],"user",{},"");
          globalUser.loggedIn();

         //await user?.sendEmailVerification();


          return true;
        }
      }
      catch (e) {
        if (password.length < 6 && password.isNotEmpty) {
          // Εμφανίζουμε μήνυμα για κωδικό μικρότερο από 6 χαρακτήρες
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(greek
                  ? "Ο κωδικός πρέπει να έχει τουλάχιστον 6 χαρακτήρες."
                  : "Password must be at least 6 characters."),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (e is FirebaseAuthException) {
          // Διαχείριση σφαλμάτων από το FirebaseAuth
          if (e.code == 'email-already-in-use') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(greek
                    ? "Αυτό το email χρησιμοποιείται ήδη. Δοκιμάστε με άλλο email."
                    : "This email is already in use. Please try another email."),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (e.code == 'invalid-email') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(greek
                    ? "Το email που καταχωρήσατε δεν είναι έγκυρο."
                    : "The email address is not valid."),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(greek
                    ? "Προέκυψε σφάλμα κατά την εγγραφή. Δοκιμάστε ξανά."
                    : "An error occurred during signup. Please try again."),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Γενικό σφάλμα
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(greek
                  ? "Προέκυψε σφάλμα κατά την εγγραφή. Δοκιμάστε ξανά."
                  : "An error occurred during signup. Please try again."),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return false;
      }
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(greek?"Αυτό το όνομα χρήστη χρησιμοποιείται ήδη! Επέλεξε κάποιο άλλο.":'This username already exists! Please try another one.'),
            duration: Duration(seconds: 2),
          ));
      return false;
    }
    return false;
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }



  //συναρτηση για ελεγχο αν υπαρχει το username
  Future<bool> isUsernameAvailable(String username) async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return userDoc
        .docs.isEmpty; // Επιστρέφει true αν το username είναι διαθέσιμο
  }

  Future<void> loadLanguage(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();

    if(querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      greek = userDoc.get("Language");
    }
  }



  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;


      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get();


      if (userDoc.exists && userDoc.data() != null)
      {
        Map<String, bool> matchKeys = {};

        try {
          final raw = userDoc['matchKeys'];
          if (raw is Map) {
            matchKeys = Map<String, bool>.from(raw);
          }
        } catch (e) {}

        globalUser = AppUser(
          userDoc.get("username").toString(),
          userDoc.get("University").toString(),
          (userDoc['Favourite Teams'] as List<dynamic>).map((e) => e.toString()).toList(),
          (userDoc['Controlled Teams'] as List<dynamic>).map((e) => e.toString()).toList(),
          userDoc['role'],
          matchKeys,
          userDoc['email']
        );

        globalUser.loggedIn();
        darkModeNotifier.value = userDoc.get("darkMode");
        if(darkModeNotifier.value) {
          isToggled = true;
        }
        else{isToggled =false;}


        await loadLanguage(username);

      }
      else
      {
        print("Error: User document does not exist or is empty.");
      }

      return true;

    } catch (e) {
      print("Error signing in: $e");
      return false;
    }

  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      if (!isValidEmail(email)){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(greek ? 'Συμπλήρωσε σωστά το email σου' : 'Please fill in your email.') ,
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(greek ? 'Ένα email επαναφοράς κωδικού στάλθηκε!' :  'A password reset email has been sent!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Δεν υπάρχει χρήστης με αυτό το email.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Σφάλμα'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }



  //συνάρτηση που προσθέτει το ονομα της ομαδας που θα μπορει να ελέγχει ο admin
  Future<void> addControlledTeamToFirestore(List<String> list) async {
    // Convert the list of Team objects to a list of maps


    if (globalUser.isAdmin && globalUser.isLoggedIn){
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'Controlled Teams': FieldValue.arrayUnion(list),
        'role': 'admin',
      }, SetOptions(merge: true));

      globalUser.addControlledTeams(list);
    }
  }


  Future<void> changeDarkMode(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;

      if (userDoc.data().containsKey("darkMode")) {
        bool currentDarkMode = userDoc["darkMode"];
        bool newDarkMode = !currentDarkMode;

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userDoc.id)
            .update({"darkMode": newDarkMode});

        //darkModeNotifier.value = !darkModeNotifier.value;
      } else {
        // Αν δεν υπάρχει, ορίζουμε την πρώτη τιμή (π.χ. true)
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userDoc.id)
            .update({"darkMode": false});

        print(
            "darkMode field did not exist, so it was created and set to true.");
      }
    }
  }



  //true == greek  else english
  Future<void> updateLanguageChoice(String username,String language) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;

      if (userDoc.data().containsKey("Language")) {

        bool nextLanguage = false;
        if(language=="English") {
          nextLanguage = false;
        } else {
          nextLanguage = true;
        }

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userDoc.id)
            .update({"Language": nextLanguage});



      }
      else {
        // Αν δεν υπάρχει, ορίζουμε την πρώτη τιμή (π.χ. true)
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userDoc.id)
            .update({"Language": true});
      }
    }
  }


  Future<String> getSelectedLanguage(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();

    if (querySnapshot.docs.first.get("Language")==true) {
      return "Ελληνικά";
    }

    return "English";
  }


  Future<void> getUser(User user)async
  {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if(userDoc.exists && userDoc.data() != null){

      Map<String, bool> matchKeys = {};

      try {
        final raw = userDoc['matchKeys'];
        if (raw is Map) {
          matchKeys = Map<String, bool>.from(raw);
        }
      } catch (e) {}

      globalUser = AppUser(
        userDoc.get("username").toString(),
        userDoc.get("University").toString(),
        (userDoc['Favourite Teams'] as List<dynamic>).map((e) => e.toString()).toList(),
        (userDoc['Controlled Teams'] as List<dynamic>).map((e) => e.toString()).toList(),
        userDoc['role'],
       matchKeys,
        userDoc['email']
      );
      globalUser.loggedIn();
      isLoggedIn = true;

      darkModeNotifier.value = userDoc.get("darkMode");
      if(darkModeNotifier.value) {
        isToggled = true;
      }
      else{isToggled =false;}

      await loadLanguage(globalUser.username);

    }
    else{
      print("Error: User document does not exist or is empty.");
    }

  }


  Future<void> addNotifyMatch(MatchDetails match) async {
    bool value;
    if (globalUser.favoriteList.contains(match.homeTeam.name) ||
        globalUser.favoriteList.contains(match.awayTeam.name) ){
      value=false;
    }
    else{
      value=true;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'matchKeys': {
        match.matchKey: value
      }
    }, SetOptions(merge: true));

  }

  Future<void> deleteNotifyMatch(MatchDetails match) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print('User not logged in');
      return;
    }

    final key = 'matchKeys.${match.matchKey}';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      key: FieldValue.delete()
    });

    print('Deleted $key successfully');
  }






}

