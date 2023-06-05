import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/service/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // login
  Future login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
  // register

  Future registerUser(String name, String email, String password) async {
    try {
      User user = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      await Database(uid: user.uid).saveUser(name, email);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // logout

  Future logout() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmail("");
      await HelperFunctions.saveUserName("");
      await auth.signOut();
    } catch (e) {
      return null;
    }
  }

  
}
