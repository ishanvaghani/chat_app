import 'package:chat_ui/models/call_model.dart';
import 'package:chat_ui/screens/pickup_screen.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;

  PickupLayout({required this.scaffold});

  FirebaseServices _firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: callStream(uid: _firebaseServices.currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            Call call = Call.fromMap(snapshot.data!.data()!);
            if(!call.hasDialled!) {
              return PickupScreen(call: call);
            }
            return scaffold;
          }
          return scaffold;
        });
  }
}
