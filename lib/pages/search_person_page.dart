import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/pages/chat_page.dart';
import 'package:chatapp_firebase/service/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'chat_person_page.dart';

class SearchPersonPage extends StatefulWidget {
  const SearchPersonPage({super.key});

  @override
  State<SearchPersonPage> createState() => _SearchPersonPageState();
}

class _SearchPersonPageState extends State<SearchPersonPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  // QuerySnapshot? searchSnapshot;
  bool _searchStarted = false;
  String userName = "";
  String userEmail = "";
  User user = FirebaseAuth.instance.currentUser!;

  List _allResults = [];
  List _resultList = [];

  List conversations = [];

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
    getClientConvos();
    searchController.addListener(onSearchChanged);
  }

  onSearchChanged() {
    searchResultList();
    setState(() {
      if (searchController.text != "") {
        _searchStarted = true;
      } else {
        _searchStarted = false;
      }
    });
  }

  searchResultList() {
    var showResults = [];
    if (searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var name = clientSnapshot['name'].toString().toLowerCase();
        var email = clientSnapshot['email']
            .toString()
            .toLowerCase()
            .substring(0, clientSnapshot['email'].toString().indexOf("@"));

        if (name.contains(searchController.text.toLowerCase()) ||
            email.contains(searchController.text.toLowerCase())) {
          showResults.add(clientSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultList = showResults;
    });
  }

  getClientStream() async {
    setState(() {
      _isLoading = true;
    });
    await Database().users.get().then((value) => setState(() {
          _isLoading = false;
          _allResults = value.docs;
        }));

    searchResultList();
  }

  getClientConvos() async {
    await Database().getUserConversations(user.uid).then((value) {
      value.get().then((values) {
        setState(() {
          conversations = values.docs;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });
    await getClientStream();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  getCurrentUserEmail() async {
    await HelperFunctions.getEmail().then((value) {
      setState(() {
        userEmail = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: CupertinoSearchTextField(
          backgroundColor: Colors.white,
          controller: searchController,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          : peopleList(),
    );
  }

  initiateSearch() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      await Database(uid: user.uid)
          .searchUsers(searchController.text)
          .then((snapshot) {
        setState(() {
          // searchSnapshot = snapshot;
          _isLoading = false;
          _searchStarted = true;
        });
      });
    }
  }

  peopleList() {
    return _searchStarted
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: _resultList.length,
            itemBuilder: (context, index) {
              return peopleTile(
                userName,
                _resultList[index]['uid'],
                _resultList[index]['name'],
                _resultList[index]['email'],
                _resultList[index]['conversations'],
              );
            },
          )
        : Container();
  }

  Widget peopleTile(String userName, String personId, String personName,
      String personEmail, List<dynamic> convo) {
    bool isStarted = false;
    for (var convos in conversations) {
      String convoId = HelperFunctions.getId(convos);
      String toCompare = "${convoId}_$personName";

      if (convo.contains(toCompare)) {
        setState(() {
          isStarted = true;
        });
      }
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.teal[700],
        child: Text(
          personName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        personName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("email: $personEmail"),
      trailing: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return InkWell(
            onTap: () async {
              if (!isStarted) {
                //           await Database(uid: user.uid).startConversation(
                //               userName, personId, personName, personEmail, userEmail);
                nextScreen(
                    context,
                    ChatPersonPage(
                      personId: personId,
                      personName: personName,
                      personEmail: personEmail,
                      userName: userName,
                      userEmail: userEmail
                    ));
              } else {
                nextScreen(
                    context,
                    ChatPersonPage(
                      personId: personId,
                      personName: personName,
                      personEmail: personEmail,
                      userName: userName,
                      userEmail: userEmail
                    ));
              }
            },
            child: isStarted
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: const Text(
                      "View Chat",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: const Text(
                      "Chat Now",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
