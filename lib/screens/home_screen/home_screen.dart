import 'package:chat_ui/models/choice_model.dart';
import 'package:chat_ui/screens/home_screen/home_tab.dart';
import 'package:chat_ui/screens/profile_screen.dart';
import 'package:chat_ui/screens/home_screen/contact_tab.dart';
import 'package:chat_ui/screens/search_screen.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/utils/permissions.dart';
import '../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'call_tab.dart';
import '../pickup_layout.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  HomeScreenChoice _selectedChoice = homeChoices[0];

  void _select(HomeScreenChoice choice) async {
    setState(() {
      _selectedChoice = choice;
    });
    if (_selectedChoice == homeChoices[0]) {
      Navigator.push(
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
            return ProfileScreen();
          },
        ),
      );
    }
  }

  @override
  void initState() {
    setUserState('Online');
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
    return WillPopScope(
      onWillPop: () {
        setUserState(DateFormat.yMMMd().add_jm().format(DateTime.now()));
        return Future.value(true);
      },
      child: DefaultTabController(
        length: 3,
        child: PickupLayout(
          scaffold: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text(
                "Chats",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                indicatorColor: Colors.transparent,
                isScrollable: true,
                tabs: [
                  Tab(
                    child: Text(
                      'CHATS',
                      style: MyTheme.tabTextStyle,
                    ),
                  ),
                  Tab(
                    child: Text(
                      'CONTACTS',
                      style: MyTheme.tabTextStyle,
                    ),
                  ),
                  Tab(
                    child: Text(
                      'CALLS',
                      style: MyTheme.tabTextStyle,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  iconSize: 30.0,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var tween =
                              Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return SearchScreen();
                        },
                      ),
                    );
                  },
                ),
                Container(
                  child: PopupMenuButton<HomeScreenChoice>(
                    onSelected: _select,
                    icon: Icon(
                      Icons.more_vert,
                      size: 30.0,
                    ),
                    itemBuilder: (BuildContext context) {
                      return homeChoices.map((HomeScreenChoice choice) {
                        return PopupMenuItem<HomeScreenChoice>(
                          value: choice,
                          child: Row(
                            children: [
                              Icon(
                                choice.icon,
                                color: MyTheme.blueGrey,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                choice.title!,
                                style: MyTheme.normalStyle,
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ],
            ),
            body: TabBarView(
              children: [
                HomeTab(),
                ContactTab(),
                CallTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
