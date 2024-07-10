import 'dart:convert';
import 'package:flutter_application_1/userauthmanager.dart';
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

  // Function to make the request
  Future<http.Response> makeRequest(String token) {
    var headers = <String, String>{
      'access': token,
      'Content-Type': 'application/json',
    };
    return http.get(url, headers: headers);
  }

  var response = await makeRequest(token!);

  if (response.statusCode == 200) {
    var data = json.decode(response.body) as List;
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else if (response.statusCode == 404) {
    return [];
  } else if (response.statusCode == 401) {
    // Token expired, attempt to refresh the token
    print('Access token expired. Refreshing token...');

    // Refresh the access token
    bool isRefreshed = await refreshAccessToken();
    if (isRefreshed) {
      // Retry the request with the new token
      token = await getAccessToken();
      response = await makeRequest(token!);

      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
    }
  } else {
    throw Exception('Failed to load vulnerable phonemes');
  }

  return []; // Return an empty list if there's an error or unsuccessful fetch
}

Future<String> testStatus() async {
  var url = Uri.parse('http://potato.seatnullnull.com/test/status');
  String? token = await getAccessToken();

  // Function to make the request
  Future<http.Response> makeRequest(String token) {
    var headers = <String, String>{
      'access': token,
      'Content-Type': 'application/json',
    };
    return http.get(url, headers: headers);
  }

  var response = await makeRequest(token!);

  if (response.statusCode == 200) {
    return 'yestest';
  } else if (response.statusCode == 404) {
    return 'notest';
  } else if (response.statusCode == 401) {
    // Token expired, attempt to refresh the token
    print('Access token expired. Refreshing token...');

    // Refresh the access token
    bool isRefreshed = await refreshAccessToken();
    if (isRefreshed) {
      // Retry the request with the new token
      token = await getAccessToken();
      response = await makeRequest(token!);

      if (response.statusCode == 200) {
        return 'yestest';
      } else if (response.statusCode == 404) {
        return 'notest';
      }
    }
  } else {
    throw Exception('Failed to load test status');
  }

  return 'error'; // Return 'error' if the token refresh fails or the request is unsuccessful
}
