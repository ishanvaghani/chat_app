import 'dart:io';

import 'package:chat_ui/models/message_model.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class MessageComposer extends StatefulWidget {
  final String? userId;
  MessageComposer({required this.userId});

  @override
  _MessageComposerState createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  File? _image;
  TextEditingController _messageController = TextEditingController();
  final _imagePicker = ImagePicker();
  Color _currentColor = Colors.blueGrey;
  List<Color> _currentColors = [
    Colors.blueGrey,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.teal,
    Colors.pink,
    Colors.black,
    Colors.brown,
  ];

  void changeColor(Color color) => setState(() => _currentColor = color);
  void changeColors(List<Color> colors) =>
      setState(() => _currentColors = colors);

  _imgFromCamera() async {
    final pickedFile = await _imagePicker.getImage(
        source: ImageSource.camera, imageQuality: 20);
    setState(() {
      _image = File(pickedFile!.path);
    });
    if (_image != null) {
      sendImage(widget.userId, _image!, widget.userId);
    }
  }

  _imgFromGallery() async {
    final pickedFile = await _imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 20);
    setState(() {
      _image = File(pickedFile!.path);
    });
    if (_image != null) {
      sendImage(widget.userId, _image!, widget.userId);
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () {
              _showPicker(context);
            },
            color: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: MyTheme.lightPurple,
              ),
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                minLines: 1,
                style: TextStyle(color: _currentColor),
                decoration: InputDecoration.collapsed(
                  hintText: "Type a message...",
                  hintStyle: MyTheme.messageStyle,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mode_edit),
            color: MyTheme.primaryColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Select a color',
                      style: MyTheme.headerStyle,
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Got it',
                            style: MyTheme.subHeaderStyle,
                          ),
                        ),
                      ),
                    ],
                    content: BlockPicker(
                      pickerColor: _currentColor,
                      onColorChanged: changeColor,
                      availableColors: _currentColors,
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _messageController.text == ""
                ? null
                : () {
                    List<dynamic> _colorCodes = [];
                    _colorCodes.add(_currentColor.red);
                    _colorCodes.add(_currentColor.green);
                    _colorCodes.add(_currentColor.blue);
                    _colorCodes.add(_currentColor.opacity);
                    sendMessage(
                      widget.userId,
                      _messageController.text,
                      widget.userId,
                      _colorCodes,
                    );
                    setState(() {
                      _messageController.text = "";
                    });
                  },
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
