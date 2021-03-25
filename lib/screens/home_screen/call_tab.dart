import 'package:chat_ui/models/log_model.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/widgets/error_body.dart';
import 'package:chat_ui/widgets/log_item.dart';
import 'package:chat_ui/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../pickup_layout.dart';

class CallTab extends StatelessWidget {
  FirebaseServices _firebaseServices = FirebaseServices();
  List<Log> _logList = [];

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: StreamBuilder<QuerySnapshot>(
        stream: _firebaseServices.callLogRef
            .doc(_firebaseServices.currentUserId)
            .collection(_firebaseServices.currentUserId)
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorBody();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ProgressBar();
          }
          if (snapshot.connectionState == ConnectionState.active) {
            _logList.clear();
            snapshot.data!.docs.forEach((DocumentSnapshot document) {
              _logList.add(Log.fromMap(document.data()!));
            });
            if (_logList.isEmpty) {
              return Center(
                child: Text(
                  'No Calls',
                  style: MyTheme.normalStyle,
                ),
              );
            }
          }
          return LogItem(
            logList: _logList,
          );
        },
      ),
    );
  }
}
