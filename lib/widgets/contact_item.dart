import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/screens/chat_screen.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';

class ContactItem extends StatelessWidget {
  final userList;
  ContactItem({this.userList});

  final _options = LiveOptions(
    showItemInterval: Duration(milliseconds: 100),
    visibleFraction: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return LiveList.options(
      itemCount: userList.length,
      options: _options,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index, animation) {
        final User user = userList[index];
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
                      var tween =
                          Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    pageBuilder: (context, animation, secondaryAnimation) {
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
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: MyTheme.lightBlueGrey,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
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
                          user.username,
                          style: MyTheme.headerStyle,
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: Text(
                            user.status,
                            style: MyTheme.normalStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}
