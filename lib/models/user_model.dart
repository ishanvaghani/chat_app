import 'dart:io';

import 'package:chat_ui/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String search;
  String imageUrl;
  String phoneNo;
  String onlineStatus;
  String status;
  List<dynamic> favoriteUsers;
  List<dynamic> blockedUsers;

  User({
    required this.id,
    required this.username,
    required this.search,
    required this.imageUrl,
    required this.phoneNo,
    required this.status,
    required this.onlineStatus,
    required this.favoriteUsers,
    required this.blockedUsers,
  });

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(
      id: map['id'],
      phoneNo: map['phoneNo'],
      imageUrl: map['imageUrl'],
      status: map['status'],
      username: map['username'],
      search: map['search'],
      onlineStatus: map['onlineStatus'],
      favoriteUsers: map['favoriteUsers'],
      blockedUsers: map['blockedUsers'],
    );
  }
}

// Firebase Authentication
final _auth = FirebaseAuth.instance;

bool isExistingUser() {
  if (_auth.currentUser != null) {
    return true;
  } else {
    return false;
  }
}

Future<String> signUpUser(String name, String phoneNo, File image) async {
  String output = "";
  String imageUrl = await uploadUserImage(image);
  if (imageUrl != 'error') {
    addUserDetails(name, phoneNo, imageUrl);
    output = "success";
  } else {
    output = 'failure';
  }
  return output;
}

Future<void> signOutUser() async {
  await _auth.signOut();
}

// Firebase Firestore
FirebaseServices _firebaseServices = FirebaseServices();

void addUserDetails(
  String name,
  String phoneNo,
  String imageUrl,
) async {
  String id = _firebaseServices.currentUserId;

  Map<String, dynamic> userMap = {
    'username': name,
    'search': name.toLowerCase(),
    'phoneNo': phoneNo,
    'id': id,
    'favoriteUsers': [],
    'imageUrl': imageUrl,
    'onlineStatus': 'online',
    'status': "Hey, I'm using chat app.",
    'blockedUsers': [],
  };

  await _firebaseServices.userRef.doc(id).set(userMap);
}

Future<User> loadUserData() async {
  final userId = _firebaseServices.currentUserId;
  late User user;
  await _firebaseServices.userRef
      .doc(userId)
      .get()
      .then((DocumentSnapshot snapshot) {
    if (snapshot.data() != null) {
      Map<dynamic, dynamic> value = snapshot.data()!;
      user = User.fromMap(value);
      user.username = value['username'];
      user.imageUrl = value['imageUrl'];
      user.status = value['status'];
      user.id = value['id'];
    }
  });
  return user;
}

Future<String> updateUserData(File? image, String? name, String? status) async {
  String output = "";
  String id = _firebaseServices.currentUserId;

  if (image == null) {
    Map<String, String?> userMap = {
      'username': name,
      'search': name!.toLowerCase(),
      'status': status,
    };
    await _firebaseServices.userRef.doc(id).update(userMap);
    output = 'success';
  } else {
    String imageUrl = await uploadUserImage(image);

    if (imageUrl != 'error') {
      Map<String, String?> userMap = {
        'username': name,
        'search': name!.toLowerCase(),
        'imageUrl': imageUrl,
        'status': status,
      };
      await _firebaseServices.userRef.doc(id).update(userMap);
      output = 'success';
    } else {
      output = 'failure';
    }
  }
  return output;
}

Future<void> setUserState(String status) async {
  Map<String, String> onlineStatusMap = {
    'onlineStatus': status,
  };
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .update(onlineStatusMap);
}

// Firebase Storage
Reference _reference =
    _firebaseServices.userStorageRef.child(_auth.currentUser!.uid);

Future<String> uploadUserImage(File image) async {
  String url = "";
  try {
    await _reference.putFile(image);
    url = await _reference.getDownloadURL();
  } on FirebaseException catch (e) {
    url = 'error';
  } catch (e) {
    url = 'error';
  }
  return url;
}
