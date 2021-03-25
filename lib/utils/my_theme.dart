import 'package:flutter/material.dart';

class MyTheme {
  static Color primaryColor = Colors.purple;
  static Color accentColor = Color(0xFFFEF9EB);
  // static Color lightPurple = Color.fromRGBO(245, 206, 254, 0.3);
  static Color lightPurple = Colors.purple.withOpacity(0.1);
  static Color lightRed = Colors.red.withOpacity(0.1);
  static Color lightGreen = Colors.green.withOpacity(0.1);
  static Color lightBlueGrey = Colors.blueGrey.withOpacity(0.1);
  static Color blueGrey = Colors.blueGrey;

  static final titleStyle = TextStyle(
    color: MyTheme.blueGrey,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );

  static final subTitleStyle = TextStyle(
    color: MyTheme.blueGrey,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
  );

  static final headerStyle = TextStyle(
    color: MyTheme.blueGrey,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  static final subHeaderStyle = TextStyle(
    color: MyTheme.primaryColor,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static final tabTextStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static final normalStyle = TextStyle(
    color: MyTheme.blueGrey,
    fontSize: 16.0,
  );

  static final timeStyle = TextStyle(
    color: MyTheme.blueGrey,
    fontSize: 14.0,
  );

  static final messageTimeStyle = TextStyle(
    color: MyTheme.blueGrey,
    fontSize: 12.0,
  );

  static final onlineStyle = TextStyle(
    color: Colors.white,
    fontSize: 12.0,
  );

  static final messageStyle = TextStyle(
    color: MyTheme.blueGrey,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
  );

  static final importantMessageStyle = TextStyle(
    color: Colors.red[400],
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
  );

  static final usernameStyle = TextStyle(
    color: Colors.white,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  static final buttonStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
}
