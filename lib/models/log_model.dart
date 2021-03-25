import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/utils/other.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'call_model.dart';
import '../services/my_encryption.dart';

class Log {
  String callerId;
  String callerName;
  String callerPic;
  String receiverId;
  String receiverName;
  String receiverPic;
  String id;
  String callStatus;
  dynamic timeStamp;
  String time;

  Log({
    required this.callerId,
    required this.callerName,
    required this.callerPic,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPic,
    required this.id,
    required this.callStatus,
    required this.timeStamp,
    required this.time,
  });

  Map<String, dynamic> toMap(Log call) {
    Map<String, dynamic> logMap = Map();
    logMap['callerId'] = call.callerId;
    logMap['callerName'] = MyEncryption.encryptAES(call.callerName);
    logMap['callerPic'] = MyEncryption.encryptAES(call.callerPic);
    logMap['receiverId'] = call.receiverId;
    logMap['receiverName'] = MyEncryption.encryptAES(call.receiverName);
    logMap['receiverPic'] = MyEncryption.encryptAES(call.receiverPic);
    logMap['id'] = call.id;
    logMap['callStatus'] = MyEncryption.encryptAES(call.callStatus);
    logMap['timeStamp'] = call.timeStamp;
    logMap['time'] = call.time;
    return logMap;
  }

  factory Log.fromMap(Map<String, dynamic> logMap) {
    return Log(
        callerId: logMap['callerId'],
        callerName: MyEncryption.decryptAES(logMap['callerName']),
        callerPic: MyEncryption.decryptAES(logMap['callerPic']),
        receiverId: logMap['receiverId'],
        receiverName: MyEncryption.decryptAES(logMap['receiverName']),
        receiverPic: MyEncryption.decryptAES(logMap['receiverPic']),
        id: logMap['id'],
        callStatus: MyEncryption.decryptAES(logMap['callStatus']),
        timeStamp: logMap['timeStamp'],
        time: logMap['time']);
  }
}

FirebaseServices _firebaseServices = FirebaseServices();

Future<void> addDialledCallLog(User from, User to) async {
  Log log = Log(
    callerId: from.id,
    callerName: from.username,
    callerPic: from.imageUrl,
    receiverId: to.id,
    receiverName: to.username,
    receiverPic: to.imageUrl,
    callStatus: CALL_STATUS_DIALLED,
    id: Uuid().v1(),
    timeStamp: FieldValue.serverTimestamp(),
    time: DateFormat.yMMMd().add_jm().format(DateTime.now()),
  );

  Map<String, dynamic> logMap = log.toMap(log);

  await _firebaseServices.callLogRef
      .doc(from.id)
      .collection(from.id)
      .doc()
      .set(logMap);
}

Future<void> addReceivedCallLog(User from, User to) async {
  Log log = Log(
    callerId: from.id,
    callerName: from.username,
    callerPic: from.imageUrl,
    receiverId: to.id,
    receiverName: to.username,
    receiverPic: to.imageUrl,
    callStatus: CALL_STATUS_MISSED,
    id: Uuid().v1(),
    timeStamp: FieldValue.serverTimestamp(),
    time: DateFormat.yMMMd().add_jm().format(DateTime.now()),
  );

  Map<String, dynamic> logMap = log.toMap(log);

  await _firebaseServices.callLogRef
      .doc(to.id)
      .collection(to.id)
      .doc()
      .set(logMap);
}

Future<void> updateReceivedCallLog(String callStatus, Call call) async {
  Log log = Log(
    callerId: call.callerId,
    callerName: call.callerName,
    callerPic: call.callerPic,
    receiverId: call.receiverId,
    receiverName: call.receiverName,
    receiverPic: call.receiverPic,
    callStatus: callStatus,
    id: Uuid().v1(),
    timeStamp: FieldValue.serverTimestamp(),
    time: DateFormat.yMMMd().add_jm().format(DateTime.now()),
  );

  Map<String, dynamic> logMap = log.toMap(log);

  await _firebaseServices.callLogRef
      .doc(call.receiverId)
      .collection(call.receiverId)
      .doc()
      .set(logMap);
}
