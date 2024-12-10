import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/home/home_page.dart';
import 'package:flutter_application_1/learninginfo/progress.dart';
import 'package:flutter_application_1/learninginfo/study_info_page.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_application_1/vulnerablesoundtest/testfinalize.dart';
import 'package:flutter_application_1/vulnerablesoundtest/updatecardweaksound.dart';
import 'package:flutter_application_1/widgets/success_dialog.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class TestCard extends StatefulWidget {
  final List<int> testIds;
  final List<String> testContents;
  final List<String> testPronunciations;
  final List<String> testEngPronunciations;
  final bool isRetest;

  const TestCard({
    super.key,
    required this.testIds,
    required this.testContents,
    required this.testPronunciations,
    required this.testEngPronunciations,
    required this.isRetest,
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
    String filePath = await getRecordingPath(fileName); // 절대 경로 가져오기

    await _recorder.startRecorder(toFile: filePath);
  }

  Future<void> _stopRecording() async {
    var path = await _recorder.stopRecorder();

    if (path != null) {
      print('Recording file saved to: $path');
      setState(() {
        _isRecording = false;
        _isRecorded = true;
      });
      await _uploadRecording(path);
    } else {
      print('Error: Recording path is null');
    }
  }

  Future<String> getRecordingPath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  // 서버로 사용자가 녹음한 오디오 전송
  Future<void> _uploadRecording(String? path) async {
    if (path != null && File(path).existsSync()) {
      print('Uploading file: $path');
      String? token = await getAccessToken();
      var url = Uri.parse('$main_url/test/${widget.testIds[_currentIndex]}');
      var request = http.MultipartRequest('POST', url);
      request.headers['access'] = token ?? '';

      request.files.add(await http.MultipartFile.fromPath('userAudio', path));
      print('Headers: ${request.headers}');
      print('Files: ${request.files}');

      try {
        var response = await request.send();
        String responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          print('Upload successful: $responseBody');
          _nextCard();
        } else {
          print('Upload failed with status: ${response.statusCode}');
          print('Response: $responseBody');
          _showUploadErrorDialog();
        }
      } catch (e) {
        print('Error uploading file: $e');
        _showUploadErrorDialog();
      }
    } else {
      print('Error: File does not exist at path $path');
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'Please try recording again.',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
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
    // 테스트했고 틀린 발음 바탕으로 학습 카드에 취약음소 표시
    if (responseCode == 200) {
      updatecardweaksound();
      title = 'Test Completed';
      content = 'You have completed the pronunciation test.';
    }
    // 테스트했는데 100점 맞았을 때
    else if (responseCode == 404) {
      title = 'Perfect Pronunciation';
      content = 'You have no mispronunciations. Well done!';
    } else {
      title = 'Error';
      content = 'An error occurred while finalizing the test.';
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height / 852;
        final double width = MediaQuery.of(context).size.width / 393;

        return SuccessDialog(
          width: width,
          height: height,
        );
      },
    );
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
          page: const MainPage(initialIndex: 2),
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
        title: const Text(
          'Pronunciation Test',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 3.8, 0),
            child: IconButton(
              icon: const Icon(
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
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 7),
                      Text('[${widget.testEngPronunciations[_currentIndex]}]',
                          style:
                              TextStyle(fontSize: 24, color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Text(
                        widget.testPronunciations[_currentIndex],
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 231, 156, 135),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: Colors.grey[300],
                            ),
                          ),
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    (_currentIndex + 1) / widget.testIds.length,
                                child: Container(
                                  decoration: const BoxDecoration(
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
                      const SizedBox(height: 10),
                      Text(
                        '${_currentIndex + 1}/${widget.testIds.length}',
                        style: const TextStyle(
                          color: Color.fromARGB(129, 0, 0, 0),
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
      // 녹음하기 버튼
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          backgroundColor:
              _isRecording ? const Color(0xFF976841) : const Color(0xFFF26647),
          elevation: 0.0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(35))),
          child: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            size: 40,
            color: const Color.fromARGB(231, 255, 255, 255),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
