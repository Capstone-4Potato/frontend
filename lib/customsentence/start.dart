import 'package:flutter/material.dart';
import 'package:flutter_application_1/customsentence/cardlistscreen.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomSentenceScreen extends StatefulWidget {
  @override
  _CustomSentenceScreenState createState() => _CustomSentenceScreenState();
}

class Sentence {
  final int id;
  final String text;

  Sentence({required this.id, required this.text});

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
      };
}

class _CustomSentenceScreenState extends State<CustomSentenceScreen> {
  final List<Sentence> _sentences = [];
  final TextEditingController _controller = TextEditingController();
  final int _maxSentences = 10;
  final int _maxChars = 25;
  final RegExp _koreanRegExp = RegExp(r'^[\uAC00-\uD7A3\s.?!]+$');

  @override
  void initState() {
    super.initState();
    // _loadSentences();
    _loadSentencesFromServer();
  }

  Future<void> _loadSentencesFromServer() async {
    String? token = await getAccessToken();
    final url = 'http://potato.seatnullnull.com/cards/custom';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'access': '$token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(response.body)['cardList'];
        setState(() {
          _sentences.addAll(
            responseData.map((data) => Sentence.fromJson(data)).toList(),
          );
        });
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh and retry the request
        print('Access token expired. Refreshing token...');

        // Refresh the token
        bool isRefreshed = await refreshAccessToken();

        if (isRefreshed) {
          // Retry request with new token
          print('Token refreshed successfully. Retrying request...');
          String? newToken = await getAccessToken();
          final retryResponse = await http.get(
            Uri.parse(url),
            headers: <String, String>{
              'access': '$newToken',
              'Content-Type': 'application/json',
            },
          );

          if (retryResponse.statusCode == 200) {
            final List<dynamic> responseData =
                json.decode(retryResponse.body)['cardList'];
            setState(() {
              _sentences.addAll(
                responseData.map((data) => Sentence.fromJson(data)).toList(),
              );
            });
          } else {
            _showErrorDialog(
                'Failed to load sentences after retry. Please try again.');
          }
        } else {
          _showErrorDialog('Failed to refresh token. Please log in again.');
        }
      } else {
        _showErrorDialog('Failed to load sentences. Please try again.');
      }
    } catch (e) {
      // Handle network request exceptions
      print("Error during the request: $e");
      _showErrorDialog('Failed to load sentences. Please try again.');
    }
  }

  Future<void> _addSentence() async {
    final text = _controller.text;

    if (text.isNotEmpty &&
        _sentences.length < _maxSentences &&
        text.length <= _maxChars &&
        _koreanRegExp.hasMatch(text)) {
      String? token = await getAccessToken();
      final url = 'http://potato.seatnullnull.com/cards/custom';
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'access': '$token',
            'Content-Type': 'application/json',
          },
          body: json.encode({'text': text}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print(responseData);
          final newSentence = Sentence.fromJson(responseData);
          setState(() {
            _sentences.add(newSentence);
            _controller.clear();
          });
        } else if (response.statusCode == 401) {
          // Token expired, attempt to refresh and retry the request
          print('Access token expired. Refreshing token...');

          // Refresh the token
          bool isRefreshed = await refreshAccessToken();

          if (isRefreshed) {
            // Retry request with new token
            print('Token refreshed successfully. Retrying request...');
            String? newToken = await getAccessToken();
            final retryResponse = await http.post(
              Uri.parse(url),
              headers: <String, String>{
                'access': '$newToken',
                'Content-Type': 'application/json',
              },
              body: json.encode({'text': text}),
            );

            if (retryResponse.statusCode == 200) {
              final responseData = json.decode(retryResponse.body);
              print(responseData);
              final newSentence = Sentence.fromJson(responseData);
              setState(() {
                _sentences.add(newSentence);
                _controller.clear();
              });
            } else {
              _showErrorDialog(
                  'Failed to add sentence after retry. Please try again.');
            }
          } else {
            _showErrorDialog('Failed to refresh token. Please log in again.');
          }
        } else {
          _showErrorDialog('Failed to add sentence. Please try again.');
        }
      } catch (e) {
        // Handle network request exceptions
        print("Error during the request: $e");
        _showErrorDialog('Failed to add sentence. Please try again.');
      }
    } else {
      _showErrorDialog(
          'Please enter a sentence in Korean with 25 characters or less.');
    }
  }

  Future<void> _deleteSentence(int index) async {
    final sentence = _sentences[index];
    String? token = await getAccessToken();
    final url = 'http://potato.seatnullnull.com/cards/custom/${sentence.id}';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'access': '$token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          _sentences.removeAt(index);
        });
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh and retry the request
        print('Access token expired. Refreshing token...');

        // Refresh the token
        bool isRefreshed = await refreshAccessToken();

        if (isRefreshed) {
          // Retry request with new token
          print('Token refreshed successfully. Retrying request...');
          String? newToken = await getAccessToken();
          final retryResponse = await http.delete(
            Uri.parse(url),
            headers: <String, String>{
              'access': '$newToken',
              'Content-Type': 'application/json',
            },
          );

          if (retryResponse.statusCode == 200) {
            print(retryResponse.body);
            setState(() {
              _sentences.removeAt(index);
            });
          }
        } else {
          _showErrorDialog('Failed to refresh token. Please log in again.');
        }
      } else {
        _showErrorDialog('Failed to delete sentence. Please try again.');
      }
    } catch (e) {
      // Handle network request exceptions
      print("Error during the request: $e");
      _showErrorDialog('Failed to delete sentence. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Input Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("End Learning"),
          content: Text("Do you want to end learning?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: Text("Continue Learning"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: Text("End"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit the learning screen
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToLearning() {
    if (_sentences.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomSentences()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Custom Sentences',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          backgroundColor: const Color(0xFFF5F5F5),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 3.8, 0),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 30,
                ),
                onPressed: _showExitDialog,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Please enter a sentence',
                  labelStyle: TextStyle(color: Colors.black26),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color(0xFFF26647),
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 246, 114, 114),
                      size: 30,
                    ),
                    onPressed:
                        _sentences.length < _maxSentences ? _addSentence : null,
                  ),
                ),
                onSubmitted: (text) => _addSentence(),
                enabled: _sentences.length < _maxSentences,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _sentences.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_sentences[index].text),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.black38,
                        ),
                        onPressed: () => _deleteSentence(index),
                      ),
                    );
                  },
                ),
              ),
              Text(
                'Number of sentences : ${_sentences.length} / $_maxSentences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sentences.isNotEmpty ? _navigateToLearning : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff26647),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text(
                  'Go to Learning',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
