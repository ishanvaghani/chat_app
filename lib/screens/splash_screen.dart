import 'dart:async';
import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/screens/auth_screen/phoneno_screen.dart';
import 'package:chat_ui/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (isExistingUser()) {
      Timer(
        Duration(milliseconds: 500),
        () => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(),
          ),
        ),
      );
    } else {
      Timer(
        Duration(milliseconds: 500),
        () => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => PhonenoScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/splash_image.png'),
      ),
    );
  }
}
