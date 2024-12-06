import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/home/customsentences/cardlistscreen.dart';
import 'package:flutter_application_1/dismisskeyboard.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomSentenceScreen extends StatefulWidget {
  const CustomSentenceScreen({super.key});

  @override
  _CustomSentenceScreenState createState() => _CustomSentenceScreenState();
}

class Sentence {
  final int id;
  final String text;
  final String engTranslation;
  final bool bookmark;
  String createdAt;

  Sentence({
    required this.id,
    required this.text,
    required this.engTranslation,
    required this.bookmark,
    required this.createdAt,
  });

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'],
      text: json['text'],
      engTranslation: json['engTranslation'],
      bookmark: json['bookmark'] ?? false,
      createdAt: json['createdAt'] ?? DateTime(2024, 10, 10).toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'engTranslation': engTranslation,
        'bookmark': bookmark,
        'createdAt': createdAt,
      };
}

class _CustomSentenceScreenState extends State<CustomSentenceScreen> {
  final List<Sentence> _sentences = [];
  final TextEditingController _controller = TextEditingController();
  final int _maxSentences = 10;
  final int _maxChars = 25;

  late Color addButtonIconColor = const Color(0xFF71706B); // + 버튼 아이콘 색
  late Color addButtonColor = Colors.transparent; // + 버튼 배경 색

  bool isLoading = false;
  bool isAddLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSentencesFromServer();
    _controller.addListener(_updateSuffixIconColor);
  }

  void _updateSuffixIconColor() {
    setState(() {
      // 텍스트가 입력된 경우 파란색, 없을 때 회색으로 설정
      addButtonIconColor = _controller.text.isNotEmpty
          ? const Color.fromARGB(255, 245, 245, 245)
          : const Color(0xFF71706B);
      addButtonColor = _controller.text.isNotEmpty
          ? const Color(0xFFF26647)
          : Colors.transparent;
    });
  }

  Future<void> _loadSentencesFromServer() async {
    String? token = await getAccessToken();
    String url = '$main_url/home/custom';
    setState(() {
      isLoading = true;
    });
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
          isLoading = false;
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
              isLoading = false;
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
    print(text);
    setState(() {
      isAddLoading = true;
    });

    if (text.isNotEmpty &&
        _sentences.length < _maxSentences &&
        text.length <= _maxChars) {
      String? token = await getAccessToken();
      String url = '$main_url/cards/custom';
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
            isAddLoading = false;
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
              if (mounted) {
                setState(() {
                  _sentences.add(newSentence);
                  _controller.clear();
                  isAddLoading = false;
                });
              }
            } else {
              _showErrorDialog(
                  'Failed to add sentence after retry. Please try again.');
            }
          } else {
            _showErrorDialog('Failed to refresh token. Please log in again.');
          }
        } else {
          print("${response.statusCode}");
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
    final url = '$main_url/cards/custom/${sentence.id}';

    setState(() {
      isAddLoading = true;
    });

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
          isAddLoading = false;
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
              isAddLoading = false;
            });
          }
        } else {
          _showErrorDialog('Failed to refresh token. Please log in again.');
          setState(() {
            isAddLoading = false;
          });
        }
      } else {
        _showErrorDialog('Failed to delete sentence. Please try again.');
        setState(() {
          isAddLoading = false;
        });
      }
    } catch (e) {
      // Handle network request exceptions
      print("Error during the request: $e");
      _showErrorDialog('Error during the request.');
      setState(() {
        isAddLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Input Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height / 852;
        final double width = MediaQuery.of(context).size.width / 393;

        return ExitDialog(
          width: width,
          height: height,
          page: const MainPage(initialIndex: 0),
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

  bool isToday(String createdAt) {
    // 현재 날짜 가져오기
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.parse(createdAt);

    // 년, 월, 일이 동일한지 비교
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: bam,
            onPressed: () {
              final int cnt = _sentences.length;
              Navigator.pop(context, cnt);
            },
          ),
          title: Text(
            'Custom Sentences',
            style: TextStyle(
              color: bam,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
          backgroundColor: const Color(0xFFF5F5F5),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                style: const TextStyle(
                  color: Color(0xFFF26647),
                ),
                cursorColor: const Color(0xFFF26647),
                decoration: InputDecoration(
                  labelText: 'Please enter a sentence',
                  labelStyle: const TextStyle(
                    color: Color(0xFF71706b),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Color.fromARGB(255, 181, 181, 181),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFBEBDB8),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFF26647),
                      width: 1.5,
                    ),
                  ),
                  suffix: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: addButtonColor,
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      color: addButtonIconColor,
                      icon: const Icon(
                        Icons.add,
                        size: 19,
                      ),
                      onPressed: _sentences.length < _maxSentences
                          ? _addSentence
                          : null,
                    ),
                  ),
                ),
                onSubmitted: (text) => _addSentence(),
                enabled: _sentences.length < _maxSentences,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFF26647)),
                      ))
                    : _sentences.isEmpty
                        ? Center(
                            child: isAddLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFF26647)),
                                  ))
                                : Container(
                                    width: 356,
                                    height: 197,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                          color: const Color(0xFFEBEBEB)),
                                    ),
                                    child: const Text(
                                      'Got a sentence you'
                                      'd like to practice pronouncing? Just write it in English, we’ll translate it into Korean and save it as a card!',
                                      style: TextStyle(
                                        color: Color(0xFF7F7E79),
                                      ),
                                    ),
                                  ),
                          )
                        : Stack(
                            children: [
                              ListView.builder(
                                reverse: true,
                                itemCount: _sentences.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEBEBEB),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.17),
                                            blurRadius: 5,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                        title: Row(
                                          children: [
                                            if (isToday(
                                                _sentences[index].createdAt))
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: primary,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _sentences[index]
                                                      .engTranslation,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  _sentences[index].text,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.black38,
                                              ),
                                              onPressed: () =>
                                                  _deleteSentence(index),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (isAddLoading)
                                const Center(
                                    child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFF26647)),
                                )),
                            ],
                          ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sentences.isNotEmpty ? _navigateToLearning : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff26647),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text(
                  'Go to Learning',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
