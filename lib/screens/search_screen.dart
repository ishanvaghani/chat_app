import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/widgets/contact_item.dart';
import 'package:chat_ui/widgets/error_body.dart';
import 'package:chat_ui/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_ui/utils/permissions.dart' as per;
import 'pickup_layout.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with WidgetsBindingObserver {
  String _search = "";
  FirebaseServices _firebaseServices = FirebaseServices();
  List<User> _userList = [];
  List<String> _contactsPhoneNumber = [];

  Future<void> _getContacts() async {
    final PermissionStatus permissionStatus =
        await per.Permissions.getContactsPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Iterable<Contact> contacts =
          await ContactsService.getContacts(withThumbnails: false);
      _contactsPhoneNumber.clear();
      contacts.toList().forEach((contact) {
        if (contact.phones != null &&
            contact.phones?.first.value != null &&
            contact.phones!.first.value!.length >= 10) {
          _contactsPhoneNumber.add(contact.phones!.first.value!
              .substring(contact.phones!.first.value!.length - 10));
        }
      });
    } else {
      print("Permission not granted");
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        setUserState('Online');
        break;
      case AppLifecycleState.inactive:
        setUserState(DateFormat.yMMMd().add_jm().format(DateTime.now()));
        break;
      case AppLifecycleState.paused:
        setUserState(DateFormat.yMMMd().add_jm().format(DateTime.now()));
        break;
      case AppLifecycleState.detached:
        setUserState(DateFormat.yMMMd().add_jm().format(DateTime.now()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back_sharp),
                      color: MyTheme.blueGrey,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: MyTheme.lightPurple,
                      ),
                      child: TextField(
                        style: TextStyle(color: MyTheme.blueGrey),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration.collapsed(
                          hintText: "Search...",
                          hintStyle: MyTheme.messageStyle,
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            _search = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              _search.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Container(
                          child: Text(
                            'Search Something',
                            style: MyTheme.messageStyle,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: FutureBuilder(
                        future: _getContacts(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return ErrorBody();
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return StreamBuilder<QuerySnapshot>(
                              stream: _firebaseServices.userRef
                                  .orderBy('search')
                                  .startAt([_search]).endAt(
                                      ['$_search\uf8ff']).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ProgressBar();
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  _userList.clear();
                                  snapshot.data!.docs.forEach((doc) {
                                    if (doc.data()!['id'] !=
                                            _firebaseServices.currentUserId &&
                                        _contactsPhoneNumber
                                            .contains(doc.data()!['phoneNo'])) {
                                      _userList.add(User.fromMap(doc.data()!));
                                    }
                                  });
                                  return _userList.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No Result Found',
                                            style: MyTheme.messageStyle,
                                          ),
                                        )
                                      : ContactItem(
                                          userList: _userList,
                                        );
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          }
                          return ProgressBar();
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
