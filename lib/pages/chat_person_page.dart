import 'dart:js_interop';

import 'package:chatapp_firebase/pages/person_info_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/db_service.dart';
import '../widgets/widgets.dart';

class ChatPersonPage extends StatefulWidget {
  final String personId;
  final String personName;
  final String personEmail;
  final String userName;
  final String userEmail;

  const ChatPersonPage(
      {super.key,
      required this.personId,
      required this.personName,
      required this.personEmail,
      required this.userName,
      required this.userEmail});

  @override
  State<ChatPersonPage> createState() => _ChatPersonPageState();
}

class _ChatPersonPageState extends State<ChatPersonPage> {
  Stream<QuerySnapshot>? chats;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  bool exists = false;

  @override
  void initState() {
    // TODO: implement initState

    // check if may chat na or wala
    // wala create a new conversation in the database
    // if meron na dont do anything
    initExists();
    // causers the error
    if (!exists) {
      // create a convo with the person
      createChat();
    }

    getChats();
    super.initState();
  }

  initExists() async {
    exists = await Database().chatExists(_uid, widget.personId);
  }

  createChat() {
    Database(uid: _uid).newConversation(widget.personName, widget.personId,
        widget.personEmail, _uid, widget.userName, widget.userEmail);
  }

  getChats() {
    Database(uid: _uid).getChats("${widget.personId}").then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.personName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(
                  context,
                  PersonInfoPage(
                    personId: widget.personId,
                    personName: widget.personName,
                    personEmail: widget.personEmail,
                  ));
            },
            icon: const Icon(Icons.info_outline),
          )
        ],
      ),
    );
  }
}
