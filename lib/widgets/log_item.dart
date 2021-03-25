import 'package:auto_animated/auto_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/models/log_model.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/utils/other.dart';
import 'package:flutter/material.dart';

class LogItem extends StatelessWidget {
  final List<Log>? logList;
  LogItem({this.logList});

  final _options = LiveOptions(
    showItemInterval: Duration(milliseconds: 100),
    visibleFraction: 0.05,
  );

  Widget getIconAndTime(String callStatus, String time) {
    Icon _icon;

    switch (callStatus) {
      case CALL_STATUS_DIALLED:
        _icon = Icon(
          Icons.call_made,
          color: Colors.green,
        );
        break;
      case CALL_STATUS_MISSED:
        _icon = Icon(
          Icons.call_missed,
          color: Colors.red,
        );
        break;
      default:
        _icon = Icon(
          Icons.call_received,
          color: MyTheme.blueGrey,
        );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _icon,
        SizedBox(
          width: 10.0,
        ),
        Text(
          time,
          style: MyTheme.normalStyle,
        ),
      ],
    );
  }

  Color getColor(String callStatus) {
    Color _color;
    switch (callStatus) {
      case CALL_STATUS_DIALLED:
        _color = MyTheme.lightGreen;
        break;
      case CALL_STATUS_MISSED:
        _color = MyTheme.lightRed;
        break;
      default:
        _color = MyTheme.lightBlueGrey;
    }
    return _color;
  }

  @override
  Widget build(BuildContext context) {
    return LiveList.options(
      itemCount: logList!.length,
      options: _options,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index, animation) {
        final Log log = logList![index];
        bool hasDialled = log.callStatus == CALL_STATUS_DIALLED;
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, -0.1),
              end: Offset.zero,
            ).animate(animation),
            child: Container(
              margin: EdgeInsets.only(
                top: 10.0,
                left: 10.0,
                right: 10.0,
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: getColor(log.callStatus),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                          hasDialled ? log.receiverPic : log.callerPic,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasDialled ? log.receiverName : log.callerName,
                            style: MyTheme.headerStyle,
                          ),
                          SizedBox(height: 5.0),
                          getIconAndTime(log.callStatus, log.time),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
