import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/token.dart';
import 'package:flutter_application_1/vulnerablesoundtest/testfinalize.dart';
import 'package:flutter_application_1/vulnerablesoundtest/updatecardweaksound.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class TestCard extends StatefulWidget {
  final List<int> testIds;
  final List<String> testContents;
  final List<String> testPronunciations;
  final List<String> testEngPronunciations;

  TestCard({
    required this.testIds,
    required this.testContents,
    required this.testPronunciations,
    required this.testEngPronunciations,
  });

  @override
  _TestCardState createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> {
  late FlutterSoundRecorder _recorder;
  bool _isRecording = false;
  bool _isRecorded = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openAudioSession();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });
    String fileName = 'audio_record_${widget.testIds[_currentIndex]}.wav';
    await _recorder.startRecorder(toFile: fileName);
  }

  Future<void> _stopRecording() async {
    var path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _isRecorded = true;
    });
    await _uploadRecording(path);
  }

  Future<void> _uploadRecording(String? path) async {
    if (path != null) {
      String? token = await getAccessToken();
      var url = Uri.parse(
          'http://potato.seatnullnull.com/test/${widget.testIds[_currentIndex]}');
      var request = http.MultipartRequest('POST', url);
      request.headers['access'] = token!;

      request.files.add(await http.MultipartFile.fromPath('userAudio', path));

      var response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('File uploaded successfully');
        print('Response body: $responseBody');
        _nextCard();
      } else {
        print('File upload failed with status: ${response.statusCode}');
        _showUploadErrorDialog();
      }
    }
  }

  void _nextCard() {
    if (_isRecorded) {
      if (_currentIndex < widget.testIds.length - 1) {
        setState(() {
          _currentIndex++;
          _isRecorded = false;
        });
      } else {
        // 마지막 카드일 경우 처리
        _showCompletionDialog();
      }
    } else {
      // 녹음이 완료되지 않았을 때 처리
      // _showErrorDialog();
    }
  }

  void _showUploadErrorDialog() {
    showDialog(
      context: context,
      //barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
            'Please try recording again.',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Color(0xFFF26647), fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog() async {
    int responseCode = await testfinalize();
    String title;
    String content;

    if (responseCode == 200) {
      updatecardweaksound();
      title = 'Test Completed';
      content = 'You have completed the pronunciation test.';
    } else if (responseCode == 404) {
      title = 'Perfect Pronunciation';
      content = 'You have no mispronunciations. Well done!';
    } else {
      title = 'Error';
      content = 'An error occurred while finalizing the test.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            content,
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Color(0xFFF26647), fontSize: 20),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainPage(initialIndex: 2)),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _recorder.closeAudioSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.70;
    double cardHeight = MediaQuery.of(context).size.height * 0.22;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pronunciation Test',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFFF26647), width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.testContents[_currentIndex],
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      SizedBox(height: 7),
                      Text('[${widget.testPronunciations[_currentIndex]}]',
                          style:
                              TextStyle(fontSize: 24, color: Colors.grey[700])),
                      SizedBox(height: 4),
                      Text('[${widget.testEngPronunciations[_currentIndex]}]',
                          style:
                              TextStyle(fontSize: 24, color: Colors.grey[700])),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.grey[300],
                            ),
                          ),
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    (_currentIndex + 1) / widget.testIds.length,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFf26647),
                                        Color(0xFFf2a647)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${_currentIndex + 1}/${widget.testIds.length}',
                        style: TextStyle(
                          color: const Color.fromARGB(129, 0, 0, 0),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          child: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            size: 40,
            color: const Color.fromARGB(231, 255, 255, 255),
          ),
          backgroundColor: _isRecording ? Color(0xFF976841) : Color(0xFFF26647),
          elevation: 0.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(35))),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
