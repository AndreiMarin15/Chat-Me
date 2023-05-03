import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final String? uid;
  Database({this.uid});

  final CollectionReference users =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groups =
      FirebaseFirestore.instance.collection("groups");

  // saving user
  Future saveUser(String name, String email) async {
    return await users.doc(uid).set({
      "name": name,
      "email": email,
      "groups": [],
      "profilepic": "",
      "uid": uid
    });
  }

  //  getting user
  Future getUser(String email) async {
    QuerySnapshot snapshot = await users.where("email", isEqualTo: email).get();
    return snapshot;
  }
}
