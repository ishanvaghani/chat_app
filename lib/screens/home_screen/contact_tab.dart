import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/widgets/contact_item.dart';
import 'package:chat_ui/widgets/error_body.dart';
import 'package:chat_ui/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:chat_ui/utils/permissions.dart' as per;
import 'package:permission_handler/permission_handler.dart';

class ContactTab extends StatelessWidget {
  List<User> _userList = [];
  List<String> _contactsPhoneNumber = [];
  FirebaseServices _firebaseServices = FirebaseServices();

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
              .substring(contact.phones!.first.value!.length - 10)
              .replaceAll(RegExp("[()\\-\\s]"), ""));
        }
      });
    } else {
      print("Permission not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
      future: _getContacts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorBody();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
            stream: _firebaseServices.userRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorBody();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ProgressBar();
              }
              if (snapshot.connectionState == ConnectionState.active) {
                _userList.clear();
                snapshot.data!.docs.forEach((DocumentSnapshot document) {
                  if ((document.data()!['id'] !=
                          _firebaseServices.currentUserId) &&
                      (_contactsPhoneNumber
                          .contains(document.data()!['phoneNo']))) {
                    _userList.add(User.fromMap(document.data()!));
                  }
                });
                if (_userList.isEmpty) {
                  return Center(
                    child: Text(
                      'No Contacts',
                      style: MyTheme.normalStyle,
                    ),
                  );
                }
              }
              return ContactItem(
                userList: _userList,
              );
            },
          );
        }
        return ProgressBar();
      },
    ));
  }
}
