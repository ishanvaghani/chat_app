import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseServices {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final userRef = FirebaseFirestore.instance.collection('Users');
  final messageRef = FirebaseFirestore.instance.collection('Messages');
  final callRef = FirebaseFirestore.instance.collection('Calls');
  final callLogRef = FirebaseFirestore.instance.collection('Call Logs');

  final userStorageRef = FirebaseStorage.instance.ref().child('Users Images');
  final messageStorageRef =
      FirebaseStorage.instance.ref().child('Messages Images');
}
