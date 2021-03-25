import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/widgets/error_body.dart';
import 'package:chat_ui/widgets/progress_bar.dart';
import 'package:chat_ui/widgets/recent_contacts_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecentContacts extends StatefulWidget {
  @override
  _RecentContactsState createState() => _RecentContactsState();
}

class _RecentContactsState extends State<RecentContacts> {
  List<User> _userList = [];
  List<dynamic> _userIdList = [];
  FirebaseServices firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: firebaseServices.userRef
              .doc(firebaseServices.currentUserId)
              .collection('Recent Users')
              .orderBy('timeStamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorBody();
            }
            if (snapshot.connectionState == ConnectionState.active) {
              _userIdList.clear();
              snapshot.data!.docs.forEach((DocumentSnapshot document) {
                _userIdList.add(document.data()!['id']);
              });
              _userList.clear();
              if (_userIdList.isEmpty) {
                return Center(
                  child: Text(
                    'No Recent Contacts',
                    style: MyTheme.normalStyle,
                  ),
                );
              }
              return FutureBuilder<QuerySnapshot>(
                future: firebaseServices.userRef.get(),
                builder: (context, userSnapshot) {
                  _userList.clear();
                  if (snapshot.hasError) {
                    return ErrorBody();
                  }
                  if (userSnapshot.connectionState == ConnectionState.done) {
                    _userIdList.forEach((userId) {
                      userSnapshot.data!.docs.forEach((doc) {
                        if (userId == doc.data()!['id']) {
                          _userList.add(User.fromMap(doc.data()!));
                        }
                      });
                    });
                    return RecentContactsItem(userList: _userList);
                  }
                  return ProgressBar();
                },
              );
            }
            return ProgressBar();
          },
        ),
      ),
    );
  }
}
