import 'package:chat_ui/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/my_encryption.dart';

class Call {
  String callerId;
  String callerName;
  String callerPic;
  String receiverId;
  String receiverName;
  String receiverPic;
  String channelId;
  bool? hasDialled;

  Call({
    required this.callerId,
    required this.callerName,
    required this.callerPic,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPic,
    required this.channelId,
    this.hasDialled,
  });

  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    callMap['callerId'] = call.callerId;
    callMap['callerName'] = MyEncryption.encryptAES(call.callerName);
    callMap['callerPic'] = MyEncryption.encryptAES(call.callerPic);
    callMap['receiverId'] = call.receiverId;
    callMap['receiverName'] = MyEncryption.encryptAES(call.receiverName);
    callMap['receiverPic'] = MyEncryption.encryptAES(call.receiverPic);
    callMap['channelId'] = call.channelId;
    callMap['hasDialled'] = call.hasDialled;
    return callMap;
  }

  factory Call.fromMap(Map<String, dynamic> callMap) {
    return Call(
      callerId: callMap['callerId'],
      callerName: MyEncryption.decryptAES(callMap['callerName']),
      callerPic: MyEncryption.decryptAES(callMap['callerPic']),
      receiverId: callMap['receiverId'],
      receiverName: MyEncryption.decryptAES(callMap['receiverName']),
      receiverPic: MyEncryption.decryptAES(callMap['receiverPic']),
      channelId: callMap['channelId'],
      hasDialled: callMap['hasDialled'],
    );
  }
}

FirebaseServices _firebaseServices = FirebaseServices();

Future<bool> makeCall({required Call call}) async {
  try {
    call.hasDialled = true;
    Map<String, dynamic> hasDialledMap = call.toMap(call);
    call.hasDialled = false;
    Map<String, dynamic> hasNotDialledMap = call.toMap(call);

    await _firebaseServices.callRef.doc(call.callerId).set(hasDialledMap);
    await _firebaseServices.callRef.doc(call.receiverId).set(hasNotDialledMap);
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> endCall({required Call call}) async {
  try {
    await _firebaseServices.callRef.doc(call.callerId).delete();
    await _firebaseServices.callRef.doc(call.receiverId).delete();
    return true;
  } catch (e) {
    return false;
  }
}

Stream<DocumentSnapshot> callStream({required String uid}) =>
    _firebaseServices.callRef.doc(uid).snapshots();
