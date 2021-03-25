import 'package:flutter/material.dart';

class HomeScreenChoice {
  const HomeScreenChoice({this.title, this.icon});

  final String? title;
  final IconData? icon;
}

const List<HomeScreenChoice> homeChoices = const <HomeScreenChoice>[
  const HomeScreenChoice(title: 'Profile', icon: Icons.person),
];

class ChatScreenChoice {
  String? title;
  Icon? icon;

  ChatScreenChoice({this.title, this.icon});
}

List<ChatScreenChoice> chatChoices = <ChatScreenChoice>[
  ChatScreenChoice(
    title: 'Add to favorite',
    icon: Icon(
      Icons.favorite_outline,
      color: Colors.blueGrey,
    ),
  ),
  ChatScreenChoice(
    title: 'Block User',
    icon: Icon(
      Icons.block,
      color: Colors.blueGrey,
    ),
  ),
];
