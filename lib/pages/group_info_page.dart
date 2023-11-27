import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/pages/home_page.dart';
import 'package:chatapp_firebase/service/db_service.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String admin;

  const GroupInfoPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.admin});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Stream? members;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  String userName = "";
  @override
  void initState() {
    getMembers();
    getCurrentUserIdandName();
    super.initState();
  }

  getMembers() async {
    Database(uid: _uid).getGroupInfo(widget.groupId).then((val) {
      setState(() {
        members = val;
      });
    });
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal[700],
        title: const Text(
          "Group Info",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        "Exit",
                      ),
                      content: const Text(
                        "Are you sure?",
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          color: Colors.red,
                        ),
                        IconButton(
                          onPressed: () {
                            Database(
                                    uid: FirebaseAuth.instance.currentUser!.uid)
                                .toggleGroupJoin(
                                    userName, widget.groupId, widget.groupName)
                                .whenComplete(() {
                              nextScreenReplace(context, const HomePage());
                            });
                          },
                          icon: const Icon(Icons.logout_outlined),
                          color: Colors.teal,
                        )
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.exit_to_app_rounded),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.teal.withOpacity(0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal[800],
                    child: Text(
                      widget.groupName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group: ${widget.groupName}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Admin: ${HelperFunctions.getName(widget.admin)}",
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      )
                    ],
                  )
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null &&
              snapshot.data['members'].length > 0) {
            return ListView.builder(
              itemCount: snapshot.data['members'].length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal[800],
                      child: Text(
                        HelperFunctions.getName(snapshot.data['members'][index])
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    title: Text(
                      HelperFunctions.getName(snapshot.data['members'][index]),
                    ),
                    subtitle: Text(
                      HelperFunctions.getId(snapshot.data['members'][index]),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return const Center(
              child: CircularProgressIndicator(color: Colors.teal));
        }
      },
    );
  }
}
