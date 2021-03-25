import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/utils/permissions.dart';
import 'package:flutter/material.dart';

import 'otp_screen.dart';

class PhonenoScreen extends StatefulWidget {
  @override
  _PhonenoScreenState createState() => _PhonenoScreenState();
}

class _PhonenoScreenState extends State<PhonenoScreen> {
  TextEditingController _countryCodeController = TextEditingController();
  TextEditingController _phoneNoController = TextEditingController();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    Permissions.getContactsPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _countryCodeController.text = "+91";
    return Scaffold(
      key: _scaffoldMessengerKey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/splash_image.png',
                height: 100.0,
                width: 100.0,
              ),
              SizedBox(
                height: 50.0,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: TextField(
                      maxLength: 4,
                      keyboardType: TextInputType.phone,
                      controller: _countryCodeController,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Phone number",
                        ),
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        controller: _phoneNoController,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_phoneNoController.text.length < 10) {
                          final snackBar = SnackBar(
                              content: Text('Enter valid phone number!'));
                          _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
                          return;
                        }
                        if (_countryCodeController.text.length < 2) {
                          final snackBar = SnackBar(
                              content: Text('Enter valid country code!'));
                          _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
                          return;
                        }
                        if (!_countryCodeController.text.startsWith('+')) {
                          final snackBar = SnackBar(
                              content: Text('Enter + before country code!'));
                          _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var tween = Tween(
                                  begin: Offset(1.0, 0.0), end: Offset.zero);
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return OtpScreen(
                                countryCode: _countryCodeController.text,
                                phoneNo: _phoneNoController.text,
                              );
                            },
                          ),
                        );
                      },
                      child: Ink(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          "Send OTP",
                          style: MyTheme.buttonStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
