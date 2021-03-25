import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import 'pickup_layout.dart';

class ImageScreen extends StatefulWidget {
  final String? imageUrl;
  ImageScreen({required this.imageUrl});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        setUserState('Online');
        break;
      case AppLifecycleState.inactive:
        setUserState(DateFormat.yMMMd().add_jm().format(DateTime.now()));
        break;
      case AppLifecycleState.paused:
        setUserState(DateFormat.yMMMd().add_jm().format(DateTime.now()));
        break;
      case AppLifecycleState.detached:
        setUserState(DateFormat.yMMMd().add_jm().format(DateTime.now()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.white,
            child: Hero(
              tag: widget.imageUrl!,
              child: InteractiveViewer(
                maxScale: 2.0,
                minScale: 1.0,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl!,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            left: 20.0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_sharp,
                color: MyTheme.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
