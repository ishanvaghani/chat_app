import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/models/call_model.dart';
import 'package:chat_ui/models/log_model.dart';
import 'package:chat_ui/utils/other.dart';
import 'package:chat_ui/utils/permissions.dart';
import 'package:flutter/material.dart';

import 'call_screen.dart';

class PickupScreen extends StatefulWidget {
  final Call call;
  PickupScreen({required this.call});

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  bool isCallMissed = true;

  @override
  void dispose() {
    if (isCallMissed) {
      updateReceivedCallLog(
        CALL_STATUS_MISSED,
        widget.call,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.call.callerPic,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.7),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Incoming...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  widget.call.callerName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 75),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.call_end,
                          color: Colors.redAccent,
                          size: 30,
                        ),
                        onPressed: () async {
                          isCallMissed = false;
                          await endCall(call: widget.call);
                          await updateReceivedCallLog(
                            CALL_STATUS_RECEIVED,
                            widget.call,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.call,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          isCallMissed = false;
                          await updateReceivedCallLog(
                            CALL_STATUS_RECEIVED,
                            widget.call,
                          );
                          await Permissions
                                  .cameraAndMicrophonePermissionsGranted()
                              ? Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => CallScreen(
                                      call: widget.call,
                                      role: ClientRole.Broadcaster,
                                    ),
                                  ),
                                )
                              : {};
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
