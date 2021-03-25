import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future<String> genrateToken(String channelName) async {
  var url = Uri.parse(
      'https://agorartctokengenrator.herokuapp.com/access_token?channelName=$channelName');
  var response = await http.get(url);
  var jsonResponse = convert.jsonDecode(response.body);
  print('token: ' + jsonResponse['token']);
  return jsonResponse['token'];
}
