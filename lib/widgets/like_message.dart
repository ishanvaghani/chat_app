import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';

class LikeMessage extends StatefulWidget {
  final scale;
  final Function? animate;

  LikeMessage({this.scale, this.animate});

  @override
  _LikeMessageState createState() => _LikeMessageState();
}

class _LikeMessageState extends State<LikeMessage> {

@override
  void initState() {
    widget.animate!();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 5.0,
      bottom: 0.0,
      child: Transform.scale(
        scale: widget.scale,
        child: Icon(
          Icons.favorite,
          color: MyTheme.primaryColor,
        ),
      ),
    );
  }
}
