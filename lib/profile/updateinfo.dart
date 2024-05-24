import 'dart:convert';
import 'package:flutter_application_1/token.dart';
import 'package:http/http.dart' as http;

Future<void> updateInfo({String? nickname, int? age, int? gender}) async {
  String? token = await getAccessToken();
  if (token == null) {
    print("Error: Access token is null");
    return;
  }

  var url = Uri.parse('http://potato.seatnullnull.com/users');

  Map<String, dynamic> body = {};
  if (nickname != null) body['name'] = nickname;
  if (age != null) body['age'] = age;
  if (gender != null) body['gender'] = gender;

  try {
    var response = await http.patch(
      url,
      headers: <String, String>{
        'access': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Info updated successfully: ${response.body}");
    } else {
      print("Failed to update info: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error updating info: $e");
  }
}
