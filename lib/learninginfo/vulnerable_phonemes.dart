import 'package:flutter/material.dart';
import 'package:flutter_application_1/learninginfo/re_test_page.dart';
import 'package:flutter_application_1/token.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VulnerablePhonemesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> phonemes;

  VulnerablePhonemesScreen({required this.phonemes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
          0.46; // Default height for the list of phonemes
    }
    // print(cardHeight);
    return Container(
      height: cardHeight,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Color.fromARGB(230, 255, 255, 255),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Vulnerable Phonemes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Expanded(child: _buildContent()),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => restartTestScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff26647),
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
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
      return Center(
        child: Text(
          'Perfect!\nThere are no vulnerable phonemes.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    } else if (phonemes.length == 1 && phonemes[0].containsKey('status')) {
      return Center(
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
              vertical: 4.0,
              horizontal: 16.0,
            ),
            child: Container(
              width: double.infinity, // Full width
              height: 60,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 1.5,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: Color.fromARGB(255, 217, 57, 57),
                    child: Text(
                      '${phoneme['rank']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    '${phoneme['phonemeText']}',
                    style: TextStyle(
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
    // No vulnerable phonemes (perfect score)
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
