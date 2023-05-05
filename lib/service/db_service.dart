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

  // getting groups of a user
  getUserGroups() async {
    return users.doc(uid).snapshots();
  }

  // create group
  Future createGroup(String userName, String id, String groupName) async {
    var data = {
      // initial data of the group to be created
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    };
    DocumentReference docRef =
        await groups.add(data); // creates the group itself

    await docRef.update({
      // initial update: Adding of the first member (admin) and groupId
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": docRef.id,
    });

    DocumentReference userRef = users.doc(uid);

    return await userRef.update({
      "groups": FieldValue.arrayUnion(["${docRef.id}_$groupName"]),
    });
  }
}
