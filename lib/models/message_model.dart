import 'dart:io';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/services/my_encryption.dart';
import 'package:chat_ui/services/sound_service.dart';
import 'package:chat_ui/utils/other.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String sender;
  final String receiver;
  final String time;
  final dynamic timeStamp;
  final String message;
  final bool isLiked;
  final bool unread;
  final List<dynamic> color;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.time,
    required this.timeStamp,
    required this.message,
    required this.isLiked,
    required this.unread,
    required this.color,
  });

  factory Message.fromMap(Map<dynamic, dynamic> map) {
    return Message(
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      isLiked: map['isLiked'],
      message: MyEncryption.decryptAES(map['message']),
      time: map['time'],
      timeStamp: map['timeStamp'],
      unread: map['unread'],
      color: map['color'],
    );
  }
}

FirebaseServices _firebaseServices = FirebaseServices();
CollectionReference _collectionReference = _firebaseServices.messageRef;

void _checkRecentUser(String? userId) async {
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .collection("Recent Users")
      .doc(userId)
      .get()
      .then((snapshot) async {
    if (snapshot.data() == null) {
      await _firebaseServices.userRef
          .doc(_firebaseServices.currentUserId)
          .collection("Recent Users")
          .doc(userId)
          .set({
        'id': userId,
        'timeStamp': FieldValue.serverTimestamp(),
      });
      await _firebaseServices.userRef
          .doc(userId)
          .collection("Recent Users")
          .doc(_firebaseServices.currentUserId)
          .set({
        'id': _firebaseServices.currentUserId,
        'timeStamp': FieldValue.serverTimestamp(),
      });
    }
  });
}

void _updateUserTimeStamp(String? userId) async {
  await _firebaseServices.userRef
      .doc(_firebaseServices.currentUserId)
      .collection("Recent Users")
      .doc(userId)
      .get()
      .then((snapshot) async {
    if (snapshot.data() != null) {
      await _firebaseServices.userRef
          .doc(userId)
          .collection("Recent Users")
          .doc(_firebaseServices.currentUserId)
          .update({
        'timeStamp': FieldValue.serverTimestamp(),
      });

      await _firebaseServices.userRef
          .doc(_firebaseServices.currentUserId)
          .collection("Recent Users")
          .doc(userId)
          .update({
        'timeStamp': FieldValue.serverTimestamp(),
      });
    }
  });
}

void sendMessage(String? userId, String message, String? receiver,
    List<dynamic> messageColor) async {
  _checkRecentUser(userId);

  final _ref = _collectionReference.doc();

  message = MyEncryption.encryptAES(message);
  Map<String, dynamic> messageMap = {
    'id': _ref.id,
    'sender': _firebaseServices.currentUserId,
    'receiver': receiver,
    'isLiked': false,
    'message': message,
    'unread': true,
    'color': messageColor,
    'timeStamp': FieldValue.serverTimestamp(),
    'time': DateFormat.jm().format(DateTime.now()),
  };
  await _ref.set(messageMap);
  // messageSendSound();
  _updateUserTimeStamp(userId);
}

void deleteMessage(String? messageId) async {
  await _collectionReference.doc(messageId).delete();
}

void sendImage(String? userId, File image, String? receiver) async {
  _checkRecentUser(userId);

  final _ref = _collectionReference.doc();
  String _defaultUrl = MyEncryption.encryptAES(defaultImageUrl);
  Map<String, dynamic> messageMap = {
    'id': _ref.id,
    'sender': _firebaseServices.currentUserId,
    'receiver': receiver,
    'isLiked': false,
    'color': <dynamic>[],
    'message': _defaultUrl,
    'unread': true,
    'timeStamp': FieldValue.serverTimestamp(),
    'time': DateFormat.jm().format(DateTime.now()),
  };
  await _ref.set(messageMap);

  String _imageUrl = await uploadImage(image);

  if (_imageUrl != 'error') {
    _imageUrl = MyEncryption.encryptAES(_imageUrl);
    Map<String, dynamic> messageMap = {
      'message': _imageUrl,
    };
    await _ref.update(messageMap);
    // messageSendSound();
    _updateUserTimeStamp(userId);
  }
}

Future<void> likeMessage(String? messageId) async {
  Map<String, dynamic> messageMap = {
    'isLiked': true,
  };
  await _collectionReference.doc(messageId).update(messageMap);
}

Future<void> dislikeMessage(String? messageId) async {
  Map<String, dynamic> messageMap = {
    'isLiked': false,
  };
  await _collectionReference.doc(messageId).update(messageMap);
}

Future<void> markReadMessage(String? userId) async {
  await _collectionReference.orderBy('timeStamp').get().then((snapshot) {
    snapshot.docs.forEach((message) async {
      if (message.data()!['sender'] == userId &&
          message.data()!['receiver'] == _firebaseServices.currentUserId &&
          message.data()!['unread'] == true) {
        Map<String, dynamic> messageMap = {
          'unread': false,
        };
        await _collectionReference
            .doc(message.data()!['id'])
            .update(messageMap);
      }
    });
  });
}

Future lastMessage(String userId) async {
  await _collectionReference
      .orderBy('timeStamp', descending: true)
      .get()
      .then((snapshot) {
    snapshot.docs.forEach((doc) {
      if ((doc.data()!['sender'] == _firebaseServices.currentUserId &&
              doc.data()!['receiver'] == userId) ||
          (doc.data()!['sender'] == userId &&
              doc.data()!['receiver'] == _firebaseServices.currentUserId)) {
        return snapshot.docs[snapshot.docs.length - 1].data()!['message'];
      }
    });
  });
}

// Firebase Storage
Reference _reference = _firebaseServices.messageStorageRef.child(Uuid().v1());

Future<String> uploadImage(File image) async {
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
