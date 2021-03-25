import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/models/message_model.dart';
import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/screens/chat_screen.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/utils/other.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecentContactsItem extends StatelessWidget {
  final userList;
  RecentContactsItem({required this.userList});

  final _options = LiveOptions(
    showItemInterval: Duration(milliseconds: 100),
    visibleFraction: 0.05,
  );
  FirebaseServices _firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return LiveList.options(
      itemCount: userList.length,
      options: _options,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index, animation) {
        final User? user = userList[index];
        return StreamBuilder<QuerySnapshot>(
          stream: _firebaseServices.messageRef
              .orderBy('timeStamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              List<Message> _messages = [];
              int _unreadMessageCount = 0;
              snapshot.data!.docs.forEach((doc) {
                if ((doc.data()!['sender'] == _firebaseServices.currentUserId &&
                        doc.data()!['receiver'] == user!.id) ||
                    (doc.data()!['sender'] == user!.id &&
                        doc.data()!['receiver'] ==
                            _firebaseServices.currentUserId)) {
                  _messages.add(Message.fromMap(doc.data()!));
                }
                if (doc.data()!['sender'] == user.id &&
                    doc.data()!['receiver'] == _firebaseServices.currentUserId &&
                    doc.data()!['unread']) {
                  _unreadMessageCount++;
                }
              });
              String _lastMessage = _messages.isNotEmpty
                  ? _messages[_messages.length - 1].message
                  : "";
              String _lastTime = _messages.isNotEmpty
                  ? _messages[_messages.length - 1].time
                  : "";
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var tween = Tween(
                                begin: Offset(1.0, 0.0), end: Offset.zero);
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return ChatScreen(user: user);
                          },
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 10.0,
                        left: 10.0,
                        right: 10.0,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _unreadMessageCount == 0
                            ? MyTheme.lightBlueGrey
                            : MyTheme.lightPurple,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Colors.grey,
                                backgroundImage: CachedNetworkImageProvider(
                                  userList[index].imageUrl,
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user!.username,
                                    style: MyTheme.headerStyle,
                                  ),
                                  SizedBox(height: 5.0),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: _lastMessage
                                            .startsWith(defaultImageUrlStart)
                                        ? Row(
                                            children: [
                                              Icon(
                                                Icons.image,
                                                color: MyTheme.blueGrey,
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Text(
                                                'Image',
                                                style: MyTheme.normalStyle,
                                              ),
                                            ],
                                          )
                                        : Text(
                                            _lastMessage,
                                            style: MyTheme.normalStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                _lastTime,
                                style: MyTheme.timeStyle,
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              _unreadMessageCount != 0
                                  ? Container(
                                      height: 20.0,
                                      width: 20.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: MyTheme.primaryColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _unreadMessageCount.toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 20.0,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return Container();
          },
        );
      },
    );
  }
}
