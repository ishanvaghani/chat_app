import 'package:chat_ui/screens/auth_screen/image_picker_screen.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

class OtpScreen extends StatefulWidget {
  final String countryCode;
  final String phoneNo;
  OtpScreen({required this.countryCode, required this.phoneNo});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String _varificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      color: MyTheme.lightPurple,
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  void _goToImagePickerScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImagePickerScreen(phoneNo: widget.phoneNo);
        },
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _verifyPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '${widget.countryCode}${widget.phoneNo}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) {
          if (value.user != null) {
            _goToImagePickerScreen();
          }
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        final snackBar = SnackBar(content: Text(e.message!));
        _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _varificationCode = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String varificationId) {
        setState(() {
          _varificationCode = varificationId;
        });
      },
      timeout: Duration(seconds: 60),
    );
  }

  Future<void> _verifyOtp() async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
            verificationId: _varificationCode,
            smsCode: _pinPutController.text,
          ))
          .then((value) => {
                if (value.user != null) {_goToImagePickerScreen()}
              });
    } catch (e) {
      FocusScope.of(context).unfocus();
      final snackBar = SnackBar(content: Text('Invalid OTP'));
      _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    _verifyPhoneNumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Verify ${widget.countryCode}-${widget.phoneNo}',
              style: MyTheme.messageStyle,
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: PinPut(
                fieldsCount: 6,
                textStyle: MyTheme.titleStyle,
                eachFieldWidth: 40.0,
                eachFieldHeight: 55.0,
                onSubmit: (pin) async {
                  await _verifyOtp();
                },
                controller: _pinPutController,
                focusNode: _pinPutFocusNode,
                submittedFieldDecoration: _pinPutDecoration,
                selectedFieldDecoration: _pinPutDecoration,
                followingFieldDecoration: _pinPutDecoration,
                pinAnimationType: PinAnimationType.scale,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await _verifyOtp();
                    },
                    child: Ink(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        "Verify OTP",
                        style: MyTheme.buttonStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
