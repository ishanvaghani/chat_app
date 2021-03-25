import 'package:html/parser.dart';
import 'package:http/http.dart';

Future<Map<String, dynamic>> fetch(String url) async {
  final client = Client();
  final response = await client.get(Uri.parse(url));
  final document = parse(response.body);

  String title = "";
  String description = "";
  String image = "";
  String favIcon = "";

  var elements = document.getElementsByTagName('meta');
  elements.forEach((tmp) {
    if (tmp.attributes['property'] == 'og:title') {
      title = tmp.attributes['content']!;
    }
    if (tmp.attributes['property'] == 'og:description') {
      description = tmp.attributes['content']!;
    }
    if (description == "" || description.isEmpty) {
      if (tmp.attributes['name'] == 'description') {
        description = tmp.attributes['content']!;
      }
    }
    if (tmp.attributes['property'] == 'og:image') {
      image = tmp.attributes['content']!;
    }
  });

  if (title == "" || title.isEmpty) {
    title = document.getElementsByTagName('title')[0].text;
  }

  var linkElements = document.getElementsByTagName('link');
  linkElements.forEach((tmp) {
    if (tmp.attributes['rel']?.contains('icon') == true) {
      favIcon = tmp.attributes['href']!;
    }
  });

  return {
    'title': title,
    'description': description,
    'image': image,
    'favIcon': favIcon,
  };
}
