import 'dart:convert';
import 'package:flutter_application_1/token.dart';
import 'package:http/http.dart' as http;

// Asynchronously fetch data from the backend
Future<List<dynamic>?> fetchData(String category, String subcategory) async {
  try {
    String? token = await getAccessToken();
    // Backend server URL
    var url = Uri.parse(
        'http://potato.seatnullnull.com/cards?category=${Uri.encodeComponent(category)}&subcategory=${Uri.encodeComponent(subcategory)}');

    // Set headers with the token
    var headers = <String, String>{
      'access': '$token',
      'Content-Type': 'application/json',
    };

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['cardList'];
      // Return the data if you need to use it after calling fetchData
      return data;
    } else if (response.statusCode == 400) {
      // Handle error: non-existing category search
      print(json.decode(response.body));
    }
  } catch (e) {
    print(e);
  }
  return null; // Return null if there's an error or unsuccessful fetch
}
