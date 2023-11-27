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
      "conversations": [],
      "profilepic": "",
      "uid": uid
    });
  }

  //  getting user
  Future getUser(String email) async {
    QuerySnapshot snapshot = await users.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // getting data of a user
  getUserData() async {
    return users.doc(uid).snapshots();
  }

  // getting conversations
  Future<CollectionReference<Object?>> getUserConversations(String? id) async {
    CollectionReference conversations;
    if (id == null) {
      conversations = users.doc(uid).collection("conversations");
      return conversations;
    } else {
      conversations = users.doc(id).collection("conversations");
      return conversations;
    }
  }

  getConversationCollection(String id) async {
    CollectionReference conversations =
        users.doc(id).collection("conversations");

    return conversations;
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
      "recentMessageTime": ""
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

  newConversation(String partnerName, String partnerId, String partnerEmail,
      String userId, String userName, String userEmail) async {
    var data = {
      // initial data of the person to be created
      "conversationWith": partnerName,
      "groupIcon": "",
      "partnerId": partnerId,
      "partnerEmail": partnerEmail,
      "messages": [],
      "recentMessage": "",
      "recentMessageSender": "",
      "recentMessageTime": ""
    };

    var data2 = {
      // initial data of the partner to be created
      "conversationWith": userName,
      "groupIcon": "",
      "partnerId": userId,
      "partnerEmail": userEmail,
      "messages": [],
      "recentMessage": "",
      "recentMessageSender": "",
      "recentMessageTime": ""
    };

    CollectionReference userConvoRef = getConversationCollection(userId);
    DocumentReference userConvoDocRef = userConvoRef.doc(partnerId);

    await userConvoDocRef.set(data);

    CollectionReference partnerConvoRef = getConversationCollection(partnerId);
    DocumentReference partnerConvoDocRef = partnerConvoRef.doc(userId);

    await partnerConvoDocRef.set(data2);
  }

  Future<bool> chatExists(String uid, String personId) async {
    CollectionReference conversations = getConversations(uid);
    // QuerySnapshot snap = await

    DocumentSnapshot person = await conversations.doc(personId).get();

    return person.exists;
  }

  // Getting the chat
  getChats(String groupId) async {
    return groups
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  getConversations(String convoId) async {
    return users
        .doc(uid)
        .collection("conversations")
        .doc(convoId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference docRef = groups.doc(groupId);
    DocumentSnapshot documentSnapshot = await docRef.get();

    return documentSnapshot['admin'];
  }

  // Getting group members

  getGroupInfo(String groupId) async {
    return groups.doc(groupId).snapshots();
  }

  // search a group
  // TODO: Implement RegEx Search
  searchGroup(String grpName) async {
    return groups
        .where('groupName', isGreaterThanOrEqualTo: grpName)
        .where('groupName', isLessThanOrEqualTo: '$grpName\uf8ff')
        .get();
  }

  searchUsers(String name) async {
    return users
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThanOrEqualTo: '$name\uf8ff')
        .where('email', isGreaterThanOrEqualTo: name)
        .where('email', isLessThanOrEqualTo: '$name\uf8ff')
        .get();
  }

// not needed but retain for future reference
  searchGrp(String grpName) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .where('groupName', isGreaterThanOrEqualTo: grpName)
        .where('groupName', isLessThanOrEqualTo: '$grpName\uf8ff')
        .get()
        .then((QuerySnapshot snapshot) {
      List<DocumentSnapshot> documents = snapshot.docs;
      List<DocumentSnapshot> filteredDocs =
          documents.where((doc) => doc['groupName'].contains(grpName)).toList();
      return filteredDocs;
    });
  }

// not needed but retain for future reference
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference docRef = users.doc(uid);
    DocumentSnapshot docSnap = await docRef.get();

    List<dynamic> group = await docSnap['groups'];

    if (group.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // andrei
  Future startConversation(String userName, String personId, String personName,
      String personEmail, String userEmail) async {
    DocumentReference userDocRef = users.doc(uid);

    DocumentReference personDocRef = users.doc(personId);

    DocumentReference convoDocRef = await newConversation(
        personName, personId, personEmail, userName, uid!, userEmail);

    await userDocRef.update({
      'conversations': FieldValue.arrayUnion(["${convoDocRef.id}_$personName"])
    });

    await personDocRef.update({
      'conversations': FieldValue.arrayUnion(["${convoDocRef.id}_$userName"])
    });
  }

  // criscela
  Future toggleGroupJoin(
      String userName, String groupId, String groupName) async {
    DocumentReference userDocRef = users.doc(uid);
    DocumentReference groupDocRef = groups.doc(groupId);

    DocumentSnapshot docSnap = await userDocRef.get();
    List<dynamic> group = await docSnap['groups'];

    if (group.contains("${groupId}_$groupName")) {
      await userDocRef.update({
        'groups': FieldValue.arrayRemove(["${groupId}_$groupName"])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocRef.update({
        'groups': FieldValue.arrayUnion(["${groupId}_$groupName"])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groups.doc(groupId).collection('messages').add(chatMessageData);
    groups.doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString()
    });
  }
}
