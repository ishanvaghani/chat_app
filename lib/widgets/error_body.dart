import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';

class ErrorBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Somthing went wrong',
        style: MyTheme.normalStyle,
      ),
    );
  }
}
