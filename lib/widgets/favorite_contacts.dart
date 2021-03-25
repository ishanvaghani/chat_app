import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/screens/chat_screen.dart';
import 'package:chat_ui/services/firebase_services.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/widgets/error_body.dart';
import 'package:chat_ui/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoriteContacts extends StatefulWidget {
  @override
  _FavoriteContactsState createState() => _FavoriteContactsState();
}

class _FavoriteContactsState extends State<FavoriteContacts> {
  List<User> _userList = [];
  List<dynamic> _userIdList = [];
  FirebaseServices firebaseServices = FirebaseServices();

  final _options = LiveOptions(
    showItemInterval: Duration(milliseconds: 100),
    visibleFraction: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Favorite Contacts',
                  style: MyTheme.headerStyle,
                ),
              ],
            ),
          ),
          Container(
            height: 120.0,
            child: StreamBuilder<DocumentSnapshot>(
              stream: firebaseServices.userRef
                  .doc(firebaseServices.currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorBody();
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  _userIdList.clear();
                  _userIdList = snapshot.data!['favoriteUsers'];
                  _userList.clear();
                  if (_userIdList.isEmpty) {
                    return Center(
                      child: Text(
                        'No Favorite Contacts',
                        style: MyTheme.normalStyle,
                      ),
                    );
                  }
                  return FutureBuilder<QuerySnapshot>(
                    future: firebaseServices.userRef.get(),
                    builder: (context, userSnapshot) {
                      _userList.clear();
                      if (userSnapshot.hasError) {
                        return ErrorBody();
                      }
                      if (userSnapshot.connectionState ==
                          ConnectionState.done) {
                        userSnapshot.data!.docs.forEach((doc) {
                          if (_userIdList.contains(doc.data()!['id'])) {
                            _userList.add(User.fromMap(doc.data()!));
                          }
                        });
                        return LiveList.options(
                          padding: EdgeInsets.only(left: 10.0),
                          options: _options,
                          scrollDirection: Axis.horizontal,
                          itemCount: _userList.length,
                          itemBuilder: (context, index, animation) {
                            return FadeTransition(
                              opacity: Tween<double>(
                                begin: 0,
                                end: 1,
                              ).animate(animation),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0.1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                // Paste you Widget
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var tween = Tween(
                                              begin: Offset(1.0, 0.0),
                                              end: Offset.zero);
                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          return ChatScreen(
                                              user: _userList[index]);
                                        },
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 15.0,
                                      left: 6.0,
                                      right: 6.0,
                                      bottom: 10.0,
                                    ),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          radius: 30.0,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            _userList[index].imageUrl,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6.0,
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: 70.0,
                                          child: Text(
                                            _userList[index].username,
                                            style: MyTheme.normalStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return ProgressBar();
                    },
                  );
                }
                return ProgressBar();
              },
            ),
          ),
        ],
      ),
    );
  }
}
