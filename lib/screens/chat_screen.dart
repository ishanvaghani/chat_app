import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/models/call_model.dart';
import 'package:chat_ui/models/message_model.dart';
import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/models/users_model.dart';
import 'package:chat_ui/screens/user_details.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/utils/permissions.dart';
import 'package:chat_ui/widgets/chat_menu.dart';
import 'package:chat_ui/widgets/message_composer.dart';
import 'package:chat_ui/widgets/message_item.dart';
import 'package:chat_ui/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import '../models/log_model.dart';
import 'pickup_layout.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final User? user;
  ChatScreen({this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  List<Message> _messages = [];
  FirebaseServices _firebaseServices = FirebaseServices();
  bool _isMeBlocked = false;
  bool _isBlocked = false;
  bool _isLoading = true;
  ScrollController _listScrollController = ScrollController();
  late User _currentUser;

  _checkBlockedStatus() async {
    setState(() {
      _isLoading = true;
    });
    _isMeBlocked = await checkMeBlocked(widget.user!.id);
    _isBlocked = await checkBlocked(widget.user!.id);
    setState(() {
      _isLoading = false;
    });
  }

  _dial(User from, User to, context) async {
    Call call = Call(
      callerId: from.id,
      callerName: from.username,
      callerPic: from.imageUrl,
      receiverId: to.id,
      receiverName: to.username,
      receiverPic: to.imageUrl,
      channelId: '${from.username}_${to.username}',
    );

    bool callMade = await makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      addDialledCallLog(from, to);
      if (widget.user!.onlineStatus != "Online") {
        addReceivedCallLog(from, to);
      }
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => CallScreen(
            call: call,
            role: ClientRole.Broadcaster,
          ),
        ),
      );
    }
  }

  _loadUser() async {
    _currentUser = await loadUserData();
  }

  @override
  void initState() {
    _checkBlockedStatus();
    _loadUser();
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
    return _isLoading
        ? PickupLayout(
            scaffold: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
              ),
              body: ProgressBar(),
            ),
          )
        : PickupLayout(
            scaffold: Scaffold(
              appBar: _isMeBlocked || _isBlocked
                  ? AppBar(
                      title: StreamBuilder<DocumentSnapshot>(
                        stream: _firebaseServices.userRef
                            .doc(widget.user!.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            final _user = snapshot.data!;
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  _user['username'],
                                  style: MyTheme.usernameStyle,
                                ),
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                      actions: [
                        ChatMenu(user: widget.user),
                      ],
                      elevation: 0.0,
                    )
                  : AppBar(
                      title: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetails(
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: _firebaseServices.userRef
                              .doc(widget.user!.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              final _user = snapshot.data;
                              return Row(
                                children: [
                                  Hero(
                                    tag: '',
                                    child: CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        widget.user!.imageUrl,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _user!['username'],
                                          style: MyTheme.usernameStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _user['onlineStatus'],
                                          style: MyTheme.onlineStyle,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                      elevation: 0.0,
                      actions: [
                        IconButton(
                          icon: Icon(
                            Icons.video_call,
                            size: 30.0,
                          ),
                          onPressed: () async {
                            await Permissions
                                    .cameraAndMicrophonePermissionsGranted()
                                ? _dial(
                                    _currentUser, widget.user!, context)
                                : {};
                            
                          },
                        ),
                        ChatMenu(user: widget.user),
                      ],
                    ),
              body: _isMeBlocked || _isBlocked
                  ? Center(
                      child: Text(
                        _isMeBlocked
                            ? '${widget.user!.username} blocked you'
                            : 'You blocked ${widget.user!.username}',
                        style: MyTheme.titleStyle,
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firebaseServices.messageRef
                                  .orderBy('timeStamp', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Somthing went wrong');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  _messages.clear();
                                  markReadMessage(widget.user!.id);
                                  snapshot.data!.docs
                                      .forEach((DocumentSnapshot document) {
                                    if ((document.data()!['sender'] ==
                                                _firebaseServices
                                                    .currentUserId &&
                                            document.data()!['receiver'] ==
                                                widget.user!.id) ||
                                        (document.data()!['sender'] ==
                                                widget.user!.id &&
                                            document.data()!['receiver'] ==
                                                _firebaseServices
                                                    .currentUserId)) {
                                      _messages.add(
                                          Message.fromMap(document.data()!));
                                    }
                                  });
                                }
                                SchedulerBinding.instance!
                                    .addPostFrameCallback((_) {
                                  _listScrollController.animateTo(
                                    _listScrollController
                                        .position.minScrollExtent,
                                    duration: Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                });
                                return ListView.builder(
                                  reverse: true,
                                  itemCount: _messages.length,
                                  controller: _listScrollController,
                                  itemBuilder: (context, index) {
                                    final Message message = _messages[index];
                                    final bool isMe = message.sender ==
                                        _firebaseServices.currentUserId;
                                    return MessageItem(
                                        isMe: isMe, message: message);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        MessageComposer(
                          userId: widget.user!.id,
                        ),
                      ],
                    ),
            ),
          );
  }
}
