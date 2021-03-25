import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/models/message_model.dart';
import 'package:chat_ui/screens/image_screen.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:chat_ui/utils/other.dart';
import 'package:chat_ui/widgets/like_message.dart';
import 'package:chat_ui/widgets/link_preview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final bool isMe;

  MessageItem({required this.message, required this.isMe});

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _scale;

  void _likeMessage() async {
    await likeMessage(widget.message.id);
  }

  void _dislikeMessage() async {
    await dislikeMessage(widget.message.id);
  }

  Future<void> _animate() async {
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.5,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    final GestureDetector senderMessage = GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () {
                      deleteMessage(widget.message.id);
                      Navigator.of(context).pop();
                    },
                    leading: Icon(Icons.delete),
                    title: Text(
                      'Delete',
                      style: MyTheme.messageStyle,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    leading: Icon(Icons.cancel),
                    title: Text(
                      'Cancle',
                      style: MyTheme.messageStyle,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
              ),
              padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.message.message.startsWith(defaultImageUrlStart))
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ImageScreen(
                              imageUrl: widget.message.message,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: widget.message.message,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.message,
                            fit: BoxFit.cover,
                            height: 200.0,
                            width: 200.0,
                            placeholder: (context, url) => Image.asset(
                              'assets/images/place_holder_image.png',
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Uri.parse(widget.message.message).isAbsolute
                        ? LinkPreview(
                            url: widget.message.message,
                            isSender: true,
                          )
                        : Text(
                            widget.message.message,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(
                                widget.message.color[0],
                                widget.message.color[1],
                                widget.message.color[2],
                                widget.message.color[3],
                              ),
                            ),
                          ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.message.time,
                        style: MyTheme.messageTimeStyle,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      widget.message.message == defaultImageUrl
                          ? Icon(
                              Icons.timelapse,
                              color: MyTheme.blueGrey,
                            )
                          : widget.message.unread
                              ? Icon(
                                  Icons.done,
                                  color: MyTheme.blueGrey,
                                )
                              : Icon(
                                  Icons.done_all,
                                  color: Theme.of(context).primaryColor,
                                ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          widget.message.isLiked
              ? LikeMessage(
                  animate: _animate,
                  scale: _scale,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
    final GestureDetector receiverMessage = GestureDetector(
      onDoubleTap: () {
        _animate();
        if (widget.message.isLiked) {
          _dislikeMessage();
        } else {
          _likeMessage();
        }
      },
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
            padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
            decoration: BoxDecoration(
              color: MyTheme.lightPurple,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.message.message.startsWith(defaultImageUrlStart))
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageScreen(
                            imageUrl: widget.message.message,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: widget.message.message,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.message,
                          fit: BoxFit.cover,
                          height: 200.0,
                          width: 200.0,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/place_holder_image.png',
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Uri.parse(widget.message.message).isAbsolute
                      ? LinkPreview(
                          url: widget.message.message,
                          isSender: false,
                        )
                      : Text(
                          widget.message.message,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(
                              widget.message.color[0],
                              widget.message.color[1],
                              widget.message.color[2],
                              widget.message.color[3],
                            ),
                          ),
                        ),
                Text(
                  widget.message.time,
                  style: MyTheme.messageTimeStyle,
                ),
              ],
            ),
          ),
          widget.message.isLiked
              ? Positioned(
                  left: 5.0,
                  bottom: 0.0,
                  child: Transform.scale(
                    scale: _scale,
                    child: Icon(
                      Icons.favorite,
                      color: MyTheme.primaryColor,
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
    if (widget.isMe)
      return senderMessage;
    else
      return receiverMessage;
  }
}
