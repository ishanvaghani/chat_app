import 'package:chat_ui/widgets/favorite_contacts.dart';
import 'package:chat_ui/widgets/recent_contacts.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          FavoriteContacts(),
          RecentContacts(),
        ],
      ),
    );
  }
}
