import 'package:flutter/material.dart';
import 'package:flutter_application_1/learninginfo/re_test_page.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VulnerablePhonemesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> phonemes;

  const VulnerablePhonemesScreen({super.key, required this.phonemes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 1, 16, 1),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    double cardHeight;

    if (phonemes.isEmpty) {
      cardHeight = MediaQuery.of(context).size.height *
          0.26; // Height for "Perfect!" message
    } else if (phonemes.length == 1 && phonemes[0].containsKey('status')) {
      cardHeight = MediaQuery.of(context).size.height *
          0.26; // Height for "No test conducted" message
    } else {
      cardHeight = MediaQuery.of(context).size.height *
          0.44; // Default height for the list of phonemes
    }
    // print(cardHeight);
    return SizedBox(
      height: cardHeight,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: const Color.fromARGB(230, 255, 255, 255),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            children: [
              const Text(
                'Vulnerable Phonemes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Expanded(child: _buildContent()),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const restartTestScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff26647),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Pronunciation Test',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (phonemes.isEmpty) {
      return const Center(
        child: Text(
          'Perfect!\nThere are no vulnerable phonemes.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    } else if (phonemes.length == 1 && phonemes[0].containsKey('status')) {
      return const Center(
        child: Text(
          'No test conducted.\nPlease take the test to check for vulnerable phonemes.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView(
        children: phonemes.map((phoneme) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 1.8,
              horizontal: 16.0,
            ),
            child: SizedBox(
              width: double.infinity, // Full width
              height: 58,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 1.5,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color.fromARGB(255, 217, 57, 57),
                    child: Text(
                      '${phoneme['rank']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    '${phoneme['phonemeText']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
  }
}

Future<List<Map<String, dynamic>>> fetchVulnerablePhonemes() async {
  var url = Uri.parse('$main_url/test/phonemes');
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
    // No vulnerable phonemes (perfect score)
    return [];
  } else if (response.statusCode == 401) {
    // 토큰이 만료된 경우
    print('Access token expired. Refreshing token...');

    // 리프레시 토큰을 사용하여 새로운 액세스 토큰을 가져옵니다.
    bool isRefreshed = await refreshAccessToken();
    if (isRefreshed) {
      // Retry the request with the new token
      token = await getAccessToken();
      response = await makeRequest(token!);

      if (response.statusCode == 200) {
        print("토큰 재발급 후 사용자 취약음소 반환");
        var data = json.decode(response.body) as List;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 404) {
        // No vulnerable phonemes (perfect score)
        return [];
      } else {
        throw Exception(
            'Failed to load vulnerable phonemes after refreshing token');
      }
    } else {
      throw Exception('Failed to refresh access token');
    }
  } else {
    throw Exception('Failed to load vulnerable phonemes');
  }
}

Future<String> testStatus() async {
  var url = Uri.parse('$main_url/test/status');
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
    // 토큰이 만료된 경우
    print('Access token expired. Refreshing token...');

    // 리프레시 토큰을 사용하여 새로운 액세스 토큰을 가져옵니다.
    bool isRefreshed = await refreshAccessToken();
    if (isRefreshed) {
      // Retry the request with the new token
      token = await getAccessToken();
      response = await makeRequest(token!);
      if (response.statusCode == 200) {
        print("토큰 재발급 후 yestest 반환");
        return 'yestest';
      } else if (response.statusCode == 404) {
        // No vulnerable phonemes (perfect score)
        print("토큰 재발급 후 notest 반환");
        return 'notest';
      } else {
        throw Exception('Failed to load test ststus after refreshing token');
      }
    } else {
      throw Exception('Failed to refresh access token');
    }
  } else {
    throw Exception('Failed to load test status');
  }
}

Future<List<Map<String, dynamic>>> checkStatusAndFetchPhonemes() async {
  var status = await testStatus();
  if (status == 'yestest') {
    return await fetchVulnerablePhonemes();
  } else {
    // Return a list containing a message for no test conducted
    return [
      {'status': 'No test conducted'}
    ];
  }
}
