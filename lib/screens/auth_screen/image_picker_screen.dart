import 'dart:io';
import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/screens/home_screen/home_screen.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends StatefulWidget {
  final phoneNo;
  ImagePickerScreen({required this.phoneNo});
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _image;
  final _imagePicker = ImagePicker();
  bool _isAuthenticating = false;
  TextEditingController _controller = TextEditingController();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  User? _user;

  _imgFromCamera() async {
    final pickedFile = await _imagePicker.getImage(
        source: ImageSource.camera, imageQuality: 10);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  _imgFromGallery() async {
    final pickedFile = await _imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 10);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(
                      Icons.photo_library,
                      color: MyTheme.blueGrey,
                    ),
                    title: new Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(
                    Icons.photo_camera,
                    color: MyTheme.blueGrey,
                  ),
                  title: new Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _authenicateUser() async {
    setState(() {
      _isAuthenticating = true;
    });
    if (_image == null) {
      final snackBar = SnackBar(content: Text('Choose Image'));
      _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
    } else if (_controller.text.isEmpty) {
      final snackBar = SnackBar(content: Text('Username is empty'));
      _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
    } else {
      String ouput =
          await signUpUser(_controller.text, widget.phoneNo, _image!);
      if (ouput == "success") {
        Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => HomeScreen(),
            ),
            (Route<dynamic> route) => false);
      } else {
        final snackBar = SnackBar(content: Text('Somthing went wrong'));
        _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
      }
    }
    setState(() {
      _isAuthenticating = false;
    });
  }

  _loadUserData() async {
    _user = await loadUserData();
    if (_user != null) {
      _controller.text = _user!.username;
    }
  }

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showPicker(context),
                  child: _image != null
                      ? Container(
                          width: 300.0,
                          height: 300.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: FileImage(_image!),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          width: 300.0,
                          height: 300.0,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                            size: 100.0,
                          ),
                        ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: MyTheme.lightPurple,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(color: MyTheme.blueGrey),
                    textInputAction: TextInputAction.next,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter Username",
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isAuthenticating
                        ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor),
                          )
                        : Expanded(
                            child: InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                _authenicateUser();
                              },
                              child: Ink(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  "Sign Up",
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
      ),
    );
  }
}
