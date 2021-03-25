import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/models/user_model.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pickup_layout.dart';

class UserDetails extends StatefulWidget {
  final User? user;
  UserDetails({required this.user});

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> with WidgetsBindingObserver {
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
    final imageSize = MediaQuery.of(context).size.width;
    return PickupLayout(
      scaffold: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: widget.user!.imageUrl,
                    child: CachedNetworkImage(
                      imageUrl: widget.user!.imageUrl,
                      fit: BoxFit.cover,
                      height: imageSize,
                      width: imageSize,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Details',
                          style: MyTheme.subHeaderStyle,
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          widget.user!.username,
                          style: MyTheme.titleStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          widget.user!.status,
                          style: MyTheme.subTitleStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          widget.user!.phoneNo,
                          style: MyTheme.subTitleStyle,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
