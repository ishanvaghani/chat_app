import 'package:chat_ui/models/choice_model.dart';
import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/models/users_model.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';

class ChatMenu extends StatefulWidget {
  final User? user;
  ChatMenu({required this.user});

  @override
  _ChatMenuState createState() => _ChatMenuState();
}

class _ChatMenuState extends State<ChatMenu> {
  bool? _isFavorite = false;
  bool? _isBlocked = false;
  ChatScreenChoice _selectedChoice = chatChoices[0];

  _checkFavorite() async {
    _isFavorite = await checkFavorite(widget.user!.id);
    if (_isFavorite!) {
      setState(() {
        chatChoices[0].icon = Icon(
          Icons.favorite_border,
          color: MyTheme.blueGrey,
        );
        chatChoices[0].title = "Remove from Favorite";
      });
    } else {
      setState(() {
        chatChoices[0].icon = Icon(
          Icons.favorite,
          color: Theme.of(context).primaryColor,
        );
        chatChoices[0].title = "Add to Favorite";
      });
    }
  }

  _checkBlocked() async {
    _isBlocked = await checkBlocked(widget.user!.id);
    if (_isBlocked!) {
      setState(() {
        chatChoices[1].icon = Icon(
          Icons.block,
          color: MyTheme.blueGrey,
        );
        chatChoices[1].title = "Unblock User";
      });
    } else {
      chatChoices[1].icon = Icon(
        Icons.block,
        color: Theme.of(context).primaryColor,
      );
      chatChoices[1].title = "Block User";
    }
  }

  _select(ChatScreenChoice choice) async {
    setState(() {
      _selectedChoice = choice;
    });
    if (_selectedChoice == chatChoices[0]) {
      if (_isFavorite!) {
        await removeFromFavorite(widget.user!.id);
        setState(() {
          _isFavorite = false;
        });
      } else {
        await addToFavorite(widget.user!.id);
        setState(() {
          _isFavorite = true;
        });
      }
      _checkFavorite();
    }
    if (_selectedChoice == chatChoices[1]) {
      if (_isBlocked!) {
        await unblockUser(widget.user!.id);
        setState(() {
          _isBlocked = false;
        });
      } else {
        await blockUser(widget.user!.id);
        setState(() {
          _isBlocked = true;
        });
      }
      _checkBlocked();
    }
  }

  @override
  void initState() {
    _checkBlocked();
    _checkFavorite();
    super.initState();
  }

  @override
  void dispose() {
    _isFavorite = null;
    _isBlocked = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopupMenuButton<ChatScreenChoice>(
        onSelected: _select,
        icon: Icon(
          Icons.more_vert,
          size: 30.0,
        ),
        itemBuilder: (BuildContext context) {
          return chatChoices.map((ChatScreenChoice choice) {
            return PopupMenuItem<ChatScreenChoice>(
              value: choice,
              child: Row(
                children: [
                  choice.icon!,
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    choice.title!,
                    style: MyTheme.normalStyle,
                  ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
