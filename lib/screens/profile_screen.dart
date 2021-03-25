import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/screens/image_screen.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name = "";
  String? _status = "";
  final _formKey = GlobalKey<FormState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _imagePicker = ImagePicker();

  bool _isUserLoading = true;
  bool _isUserUpdating = false;
  File? _image;
  late User _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    _user = await loadUserData();
    setState(() {
      _isUserLoading = false;
      _name = _user.username;
      _status = _user.status;
    });
  }

  _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUserUpdating = true;
      });
      String output = await updateUserData(_image, _name, _status);
      if (output == "success") {
        final snackBar = SnackBar(content: Text('Succesfully Updated'));
        _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
        setState(() {
          _isUserUpdating = false;
        });
      } else {
        final snackBar = SnackBar(content: Text(output));
        _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
        setState(() {
          _isUserUpdating = false;
        });
      }
    }
  }

  _imgFromCamera() async {
    final pickedFile = await _imagePicker.getImage(
        source: ImageSource.camera, imageQuality: 30);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  _imgFromGallery() async {
    final pickedFile = await _imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 30);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: MyTheme.blueGrey,
                    ),
                    title: Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: Icon(
                    Icons.photo_camera,
                    color: MyTheme.blueGrey,
                  ),
                  title: Text('Camera'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        elevation: 0.0,
      ),
      key: _scaffoldMessengerKey,
      body: _isUserLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            )
          : Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ImageScreen(
                                  imageUrl: _user.imageUrl,
                                ),
                              ),
                            );
                          },
                          child: _image != null
                              ? Container(
                                  width: 150.0,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: FileImage(_image!),
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Hero(
                                      tag: _user.imageUrl,
                                      child: CircleAvatar(
                                        radius: 75.0,
                                        backgroundColor: Colors.grey,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          _user.imageUrl,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      child: GestureDetector(
                                        onTap: () => _showPicker(context),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          child: Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: MyTheme.lightPurple,
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: MyTheme.blueGrey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      bottom: 5.0,
                                      right: 5.0,
                                    ),
                                  ],
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
                          child: TextFormField(
                            style: TextStyle(color: MyTheme.blueGrey),
                            keyboardType: TextInputType.name,
                            initialValue: _user.username,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              setState(() {
                                _name = value.trim();
                              });
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Username can not be empty";
                              }
                              return null;
                            },
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
                        Container(
                          decoration: BoxDecoration(
                            color: MyTheme.lightPurple,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            style: TextStyle(color: MyTheme.blueGrey),
                            initialValue: _user.status,
                            onChanged: (value) {
                              setState(() {
                                _status = value.trim();
                              });
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Status can not be empty";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter Status",
                              labelText: "Status",
                              prefixIcon: Icon(Icons.featured_play_list),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isUserUpdating
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor),
                                  )
                                : Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        _updateUserData();
                                      },
                                      child: Ink(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                          "Save",
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
            ),
    );
  }
}
