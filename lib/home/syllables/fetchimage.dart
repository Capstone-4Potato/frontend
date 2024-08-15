import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List> fetchImage(String pictureUrl) async {
  const String baseUrl = 'http://www.potato.seatnullnull.com';
  final String url = '$baseUrl$pictureUrl';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image');
  }
}
