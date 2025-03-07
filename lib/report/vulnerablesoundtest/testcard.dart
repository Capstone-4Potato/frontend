import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_application_1/report/vulnerablesoundtest/testfinalize.dart';
import 'package:flutter_application_1/report/vulnerablesoundtest/updatecardweaksound.dart';
import 'package:flutter_application_1/new/widgets/recording_error_dialog.dart';
import 'package:flutter_application_1/widgets/success_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class TestCard extends StatefulWidget {
  final List<int> testIds;
  final List<String> testContents;
  final List<String> testTranslations;
  final List<String> testEngPronunciations;
  final bool isRetest;
  final int exitIndex;

  const TestCard({
    super.key,
    required this.testIds,
    required this.testContents,
    required this.testTranslations,
    required this.testEngPronunciations,
    required this.isRetest,
    required this.exitIndex,
  });

  @override
  _TestCardState createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> {
  late FlutterSoundRecorder _recorder;
  bool _isRecording = false;
  bool _isRecorded = false;
  int _currentIndex = 0;

  bool _isLoading = false; // 로딩 중인지

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
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
    setState(() {
      _isLoading = true;
    });
    if (path != null && File(path).existsSync()) {
      print('Uploading file: $path');

      String? token = await getAccessToken();
      var url = Uri.parse('$main_url/test/${widget.testIds[_currentIndex]}');

      // multipart/form-data 요청 생성
      var request = http.MultipartRequest('POST', url);
      request.headers['access'] = token ?? '';

      // 'userAudio' 필드에 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath(
          'userAudio', // 서버에서 요구하는 필드명
          path, // 파일 경로
        ),
      );

      print('Headers: ${request.headers}');
      print('Files: ${request.files}');

      try {
        var response = await request.send();
        String responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          print('Upload successful: $responseBody');
          _nextCard();
          setState(() {
            _isLoading = false;
          });
        } else {
          print('Upload failed with status: ${response.statusCode}');
          print('Response: $responseBody');
          _showUploadErrorDialog();
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error uploading file: $e');
        _showUploadErrorDialog();
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Error: File does not exist at path $path');
      setState(() {
        _isLoading = false;
      });
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
      _showUploadErrorDialog();
    }
  }

  void _showUploadErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecordingErrorDialog();
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
          subtitle: "You did a great job in the test!",
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeNav(
                        bottomNavIndex: 1,
                      )),
              (route) => false,
            );
          },
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
          page: HomeNav(
            bottomNavIndex: widget.exitIndex,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
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
                      Text(
                        widget.testContents[_currentIndex],
                        style: TextStyle(
                            fontSize: 40.h, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 7.h),
                      Text(
                        '[${widget.testEngPronunciations[_currentIndex]}]',
                        style:
                            TextStyle(fontSize: 24.h, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.testTranslations[_currentIndex],
                        style: TextStyle(
                          fontSize: 24.h,
                          color: const Color.fromARGB(255, 231, 156, 135),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
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
                                widthFactor: (30 -
                                        widget.testIds.length +
                                        _currentIndex +
                                        1) /
                                    30,
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
                      SizedBox(height: 10.h),
                      Text(
                        '${30 - widget.testIds.length + _currentIndex + 1}/30',
                        style: const TextStyle(
                          color: Color.fromARGB(129, 0, 0, 0),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 80.h,
                      ),
                      if (_isLoading)
                        Center(
                            child: CircularProgressIndicator(
                          color: primary,
                        )),
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
