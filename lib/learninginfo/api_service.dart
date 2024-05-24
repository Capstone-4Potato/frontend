import 'dart:convert';
import 'package:flutter_application_1/token.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> checkTestAndFetchPhonemes() async {
  var status = await testStatus();
  if (status == 'yestest') {
    var phonemes = await fetchVulnerablePhonemes();
    if (phonemes.isEmpty) {
      return {'status': 'perfect', 'phonemes': phonemes};
    } else {
      return {'status': 'yestest', 'phonemes': phonemes};
    }
  } else {
    return {'status': 'notest', 'phonemes': []};
  }
}

Future<List<Map<String, dynamic>>> fetchVulnerablePhonemes() async {
  var url = Uri.parse('http://potato.seatnullnull.com/test/phonemes');
  String? token = await getAccessToken();

  var headers = <String, String>{
    'access': '$token',
    'Content-Type': 'application/json',
  };
  var response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    var data = json.decode(response.body) as List;
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else if (response.statusCode == 404) {
    return [];
  } else {
    throw Exception('Failed to load vulnerable phonemes');
  }
}

Future<String> testStatus() async {
  var url = Uri.parse('http://potato.seatnullnull.com/test/status');
  String? token = await getAccessToken();

  var headers = <String, String>{
    'access': '$token',
    'Content-Type': 'application/json',
  };
  var response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    return 'yestest';
  } else if (response.statusCode == 404) {
    return 'notest';
  } else {
    throw Exception('Failed to load test status');
  }
}
