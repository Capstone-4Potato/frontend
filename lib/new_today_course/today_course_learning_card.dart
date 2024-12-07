import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/home/syllables/fetchimage.dart';
import 'package:flutter_application_1/home/syllables/syllablefeedbackui.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/ttsservice.dart';
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

class TodayCourseLearningCard extends StatefulWidget {
  List<int> ids = [];
  List<String> texts = [];
  List<String> correctAudios = [];

  List<String> cardTranslations = [];
  List<String> cardPronunciations = [];
  List<String> pictureUrls = [];
  List<String> explanations = [];

  List<bool> weakCards = [];
  List<bool> bookmarks = [];

  TodayCourseLearningCard({
    super.key,
    required this.ids,
    required this.texts,
    required this.correctAudios,
    required this.cardTranslations,
    required this.cardPronunciations,
    required this.pictureUrls,
    required this.explanations,
    required this.weakCards,
    required this.bookmarks,
  });

  @override
  _TodayCourseLearningCardState createState() =>
      _TodayCourseLearningCardState();
}

class _TodayCourseLearningCardState extends State<TodayCourseLearningCard> {
  late FlutterSoundRecorder _recorder;
  late String _recordedFilePath; // 녹음된 파일 경로

  bool _isRecording = false;
  bool _isRecorded = false;
  bool _canRecord = false;
  int _currentIndex = 0;

  bool _isLoading = false; // 피드백 로딩 중인지 여부
  Uint8List? _imageData; // 이미지를 저장할 변수
  bool _isImageLoading = true; // 이미지 로딩 중인지 여부

  audioplayers.AudioPlayer audioPlayer = audioplayers.AudioPlayer();

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _loadImage();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openAudioSession();
  }

  // Base64 오디오 데이터를 디코딩하고 AudioPlayer로 재생
  void _playBase64Audio(int currentIndex) async {
    // Base64로 인코딩된 오디오 데이터를 디코딩
    Uint8List audioBytes = base64Decode(widget.correctAudios[currentIndex]);

    // 파일 경로 얻기
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDirectory.path}/audio.mp3';

    // 파일로 저장
    File audioFile = File(filePath);
    await audioFile.writeAsBytes(audioBytes);

    // 저장된 파일 재생
    await audioPlayer.play(audioplayers.DeviceFileSource(filePath));
  }

  void _onListenPressed(int currentIndex) async {
    _playBase64Audio(currentIndex);
    setState(() {
      _canRecord = true;
    });
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });
    String fileName = 'audio_record_${widget.ids[_currentIndex]}.wav';
    await _recorder.startRecorder(toFile: fileName);
  }

// 멈춤 버튼 누를 때 파일 전송
  Future<void> _stopRecording() async {
    var path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _isRecorded = true;
    });
    await _uploadRecording(path);
  }

  // 오디오 녹음 및 처리
  Future<void> _recordAudio() async {
    if (_isRecording) {
      final path = await _recorder.stopRecorder(); // 녹음 중단
      print('녹음 중단!');
      if (path != null) {
        setState(() {
          _isRecording = false; // 녹음 상태 해체
          _recordedFilePath = path; // 녹음된 파일 경로 저장
          _isLoading = true; // 로딩 시작
        });

        final audioFile = File(path); // 녹음된 파일 불러오기
        final fileBytes = await audioFile.readAsBytes(); // 파일을 바이트로 읽기
        final base64userAudio = base64Encode(fileBytes); // Base64 인코딩
        debugPrint("유저 : $base64userAudio");
        final currentCardId = widget.ids[_currentIndex];
        final base64correctAudio = widget.correctAudios[_currentIndex];
        print("정답 : $base64correctAudio");

        final feedbackData = await getFeedback(
            currentCardId, base64userAudio, base64correctAudio); // 피드백 데이터 가져오기

        if (mounted && feedbackData != null) {
          setState(() {
            _isLoading = false; // 로딩 종료
          });
          showFeedbackDialog(context, feedbackData); // 피드백 다이얼로그 표시
        } else {
          setState(() {
            _isLoading = false; // 로딩 종료
            _showUploadErrorDialog(); // 오류 다이얼로그 표시
          });
        }
      }
    } else {
      await _recorder.startRecorder(
        toFile: 'audio_record.wav',
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true; // 녹음 상태 활성화
      });
    }
  }

  // 서버로 사용자가 녹음한 오디오 전송
  Future<void> _uploadRecording(String? userAudioPath) async {
    if (userAudioPath != null) {
      String? token = await getAccessToken();
      var url = Uri.parse('$main_url/cards/${widget.ids[_currentIndex]}');

      // userAudioPath와 correctAudioPath를 base64로 인코딩
      String userAudioBase64 =
          base64Encode(await File(userAudioPath).readAsBytes());
      String correctAudioBase64 = widget.correctAudios[_currentIndex];

      // JSON Body 생성
      Map<String, String> body = {
        "userAudio": userAudioBase64,
        "correctAudio": correctAudioBase64,
      };

      try {
        // POST 요청
        var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'access': token!,
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          print('File uploaded successfully');
          print('Response body: $response.body');
          _nextCard();
        } else if (response.statusCode == 401) {
          // Token expired, attempt to refresh the token
          print('Access token expired. Refreshing token...');

          // Refresh the access token
          bool isRefreshed = await refreshAccessToken();
          if (isRefreshed) {
            // Retry the upload request with the new token
            token = await getAccessToken();
            var retryResponse = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'access': token!,
              },
              body: jsonEncode(body),
            );
            if (retryResponse.statusCode == 200) {
              print('File uploaded successfully after token refresh');
              print('Response body: $response.body');
              _nextCard();
            } else {
              print(
                  'File upload failed after token refresh with status: ${retryResponse.statusCode}');
              _showUploadErrorDialog();
            }
          } else {
            print('Failed to refresh access token');
            _showUploadErrorDialog();
          }
        } else {
          print('File upload failed with status: ${response.statusCode}');
          _showUploadErrorDialog();
        }
      } catch (e) {
        print('Error uploading file: $e');
        _showUploadErrorDialog();
      }
    }
  }

  // 이미지 로드
  Future<void> _loadImage() async {
    try {
      setState(() {
        _isImageLoading = true;
      });
      final imageData =
          await fetchImage(widget.pictureUrls[_currentIndex]); // 이미지 데이터 가져오기
      if (mounted) {
        // dispose() 이후 setState 방지
        setState(() {
          _isImageLoading = false;
          _imageData = imageData; // 이미지 데이터 갱신
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  void _nextCard() {
    if (_isRecorded) {
      if (_currentIndex < widget.ids.length - 1) {
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

  // 피드백 다이얼로그 표시
  void showFeedbackDialog(BuildContext context, FeedbackData feedbackData) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Feedback",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform(
          transform: Matrix4.translationValues(0.0, 140, 0.0),
          child: Opacity(
            opacity: animation.value,
            child: FeedbackUI(
              feedbackData: feedbackData,
              recordedFilePath: _recordedFilePath,
              text: widget.texts[_currentIndex],
            ),
          ),
        );
      },
    );
  }

  void _showUploadErrorDialog() {
    if (mounted) {
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
          'Today\'s Course!',
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
                      Text(widget.texts[_currentIndex],
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 7),
                      Text('[${widget.cardPronunciations[_currentIndex]}]',
                          style:
                              TextStyle(fontSize: 24, color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF26647),
                          minimumSize: const Size(220, 40),
                        ),
                        onPressed: () {
                          _onListenPressed(_currentIndex);
                        },
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Listen',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
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
                                    (_currentIndex + 1) / widget.ids.length,
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
                        '${_currentIndex + 1}/${widget.ids.length}',
                        style: const TextStyle(
                          color: Color.fromARGB(129, 0, 0, 0),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _isImageLoading // 이미지 로딩 중 표시
                          ? const SizedBox(
                              width: 300,
                              height: 250,
                              child: Center(child: CircularProgressIndicator()))
                          : Image.memory(
                              _imageData!,
                              fit: BoxFit.contain,
                              width: 300,
                              height: 250,
                            ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Text(
                          widget.explanations[_currentIndex],
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
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
          onPressed: _recordAudio,
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
