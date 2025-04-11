import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Data_Classes/AppUser.dart';
import '../globals.dart';

class UserHandleBase
{

  User? user;


  final FirebaseAuth database = FirebaseAuth.instance; // Αναφορά στη βάση


  //Επιστρέφει true αν συνδεθει και false αν το username υπάρχει ήδη ή συναντήσει πρόβλημα
  Future<bool> signUpWithUsername(String username, String password,String uni,BuildContext context) async
  {
    if (await isUsernameAvailable(username))
    {
      try {
        String email = "$username@myapp.com"; // Αυτόματη μετατροπή σε email

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
            "Favourite Teams":[" "],
            "Controlled Teams":[" "],
            "darkMode":false,
            "Language":true
          });


          globalUser = AppUser(username, uni, [], []);
          return true;
        }
      }
      catch (e) {
        if(password.length<6 && password.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(greek
                    ? "Ο κωδικός πρέπει να έχει μήκος τουλάχιστον 6."
                    : "Password must be at least 6 characters long"),
                duration: Duration(seconds: 2),
              ));
        }
        return false;
      }
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(greek?"Αυτό το όνομα χρησιμοποιείται ήδη! Επέλεξε κάποιο άλλο.":'This username already exists! Please try another one.'),
            duration: Duration(seconds: 2),
          ));
      return false;
    }
    return false;
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



  Future<bool> login(String username, String password) async {
    try {
      String email = "$username@myapp.com"; // Αυτόματη μετατροπή σε email


      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );



      user = userCredential.user;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get();
      if (userDoc.exists && userDoc.data() != null)
      {
        globalUser = AppUser(
          userDoc.get("username").toString(),
          userDoc.get("University").toString(),
          (userDoc['Favourite Teams'] as List<dynamic>).map((e) => e.toString()).toList(),
          (userDoc['Controlled Teams'] as List<dynamic>).map((e) => e.toString()).toList(),
        );

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


      print("${userDoc.get("username")} ${userDoc.get("University")} ${(userDoc['Favourite Teams'] as List<dynamic>).map((e) => e.toString()).toList().first} ${(userDoc['Controlled Teams'] as List<dynamic>).map((e) => e.toString()).toList().first}");
      globalUser = globalUser;


      print("object");
      return true;

    } catch (e) {
      print("Error signing in: $e");
      return false;
    }

    return false;
  }


  //συνάρτηση που προσθέτει το ονομα της ομαδας που θα μπορει να ελέγχει ο admin
  Future<void> addControlledTeamToFirestore(List<String> list) async {
    // Convert the list of Team objects to a list of maps


    if (globalUser.isAdmin && globalUser.isLoggedIn){
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(
              {'Controlled Teams': FieldValue.arrayUnion(list)},
              SetOptions(
                  merge: true)); // Use merge to avoid overwriting other fields

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

}

