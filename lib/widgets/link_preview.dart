import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_ui/services/fetch_url_preview.dart';
import 'package:chat_ui/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPreview extends StatefulWidget {
  final url;
  final isSender;
  LinkPreview({required this.url, required this.isSender});

  @override
  _LinkPreviewState createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  late Map<String, dynamic> urlPreview;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: fetch(widget.url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GestureDetector(
            onTap: () {
              _launchURL(widget.url);
            },
            child: Text(
              widget.url,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14.0,
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.isSender ? Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: snapshot.data!['image'],
                  height: 100.0,
                  width: 100.0,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/place_holder_image.png',
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.data!['title'],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: MyTheme.blueGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        snapshot.data!['description'],
                        style: TextStyle(
                          fontSize: 14.0,
                          color: MyTheme.blueGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () {
                          _launchURL(widget.url);
                        },
                        child: Text(
                          widget.url,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ) : Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.data!['title'],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: MyTheme.blueGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        snapshot.data!['description'],
                        style: TextStyle(
                          fontSize: 14.0,
                          color: MyTheme.blueGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () {
                          _launchURL(widget.url);
                        },
                        child: Text(
                          widget.url,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                CachedNetworkImage(
                  imageUrl: snapshot.data!['image'],
                  height: 100.0,
                  width: 100.0,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/place_holder_image.png',
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
