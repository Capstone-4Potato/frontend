import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/home/words/wordfeedbackui.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/permissionservice.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/widgets/recording_error_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TodayLearningCard extends StatefulWidget {
  int cardId;

  TodayLearningCard({
    Key? key,
    required this.cardId,
  }) : super(key: key);

  @override
  State<TodayLearningCard> createState() => _TodayLearningCardState();
}

class _TodayLearningCardState extends State<TodayLearningCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final PermissionService _permissionService = PermissionService();
  bool _isRecording = false;
  bool _canRecord = false;
  late String _recordedFilePath;

  bool _isLoading = false;

  String cardText = '';
  String cardPronunciation = '';
  String cardSummary = '';
  String cardCorrectAudio = '';

  @override
  void initState() {
    super.initState();
    _initialize();
    fetchData();
  }

  Future<void> _initialize() async {
    await _permissionService.requestPermissions();
    await _audioRecorder.openAudioSession();
  }

  // 학습카드 리스트 API (음절, 단어, 문장)
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? token = await getAccessToken();
      // Backend server URL
      var url = Uri.parse('$main_url/cards/today/${widget.cardId}');

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
        var data = json.decode(response.body);
        setState(() {
          cardText = data['text'];
          cardPronunciation = data['cardPronunciation'];
          cardSummary = data['cardSummary'];
          cardCorrectAudio = data['correctAudio'];
          _isLoading = false;
        });
        print("테스트 입니다: ${response.body}");
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
            var data = json.decode(response.body);
            setState(() {
              cardText = data['text'];
              cardPronunciation = data['cardPronunciation'];
              cardSummary = data['cardSummary'];
              cardCorrectAudio = data['correctAudio'];
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
    return; // Return null if there's an error or unsuccessful fetch
  }

  Future<void> _recordAudio() async {
    if (_isRecording) {
      final path = await _audioRecorder.stopRecorder();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _recordedFilePath = path;
          _isLoading = true; // 로딩 시작
        });
        final audioFile = File(path);
        print(path);
        final fileBytes = await audioFile.readAsBytes();
        final base64userAudio = base64Encode(fileBytes);
        final base64correctAudio = TtsService.instance.base64CorrectAudio;

        if (base64correctAudio != null) {
          final feedbackData = await getTodayFeedback(
              widget.cardId, base64userAudio, base64correctAudio);

          if (mounted && feedbackData != null) {
            setState(() {
              _isLoading = false; // 로딩 종료
            });
            showFeedbackDialog(context, feedbackData);
          } else {
            setState(() {
              _isLoading = false; // 로딩 종료
              showErrorDialog();
            });
          }
        } else {
          setState(() {
            _isLoading = false; // 로딩 종료
          });
        }
      }
    } else {
      await _audioRecorder.startRecorder(
        toFile: 'audio_record.wav',
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _onListenPressed() async {
    // 여기서 cardCorrectAudio 재생
    try {
      // 1. base64 문자열을 디코딩
      Uint8List audioBytes = base64Decode(cardCorrectAudio);

      // 2. 임시 디렉터리에 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/correct_audio.wav';
      final audioFile = File(filePath);
      await audioFile.writeAsBytes(audioBytes);

      // 3. 파일 재생
      await _audioPlayer.play(DeviceFileSource(filePath));
      setState(() {
        _canRecord = true; // 재생 후 녹음 활성화
      });
    } catch (e) {
      print("오디오 재생 중 오류 발생: $e");
    }
    setState(() {
      _canRecord = true;
    });
  }

  void showFeedbackDialog(BuildContext context, FeedbackData feedbackData) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Feedback",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return WordFeedbackUI(
          feedbackData: feedbackData,
          recordedFilePath: _recordedFilePath,
          text: cardText, // 카드 한글 발음
        );
      },
    );
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecordingErrorDialog();
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
          page: const MainPage(initialIndex: 0),
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.closeAudioSession();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.70;
    double cardHeight = MediaQuery.of(context).size.height * 0.27;

    return Scaffold(
      appBar: AppBar(
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
        padding: const EdgeInsets.only(top: 12),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: primary,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: cardWidth,
                            height: cardHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: const Color(0xFFF26647), width: 3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  cardText,
                                  style: TextStyle(
                                      fontSize: 36.h,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "[$cardPronunciation]",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.grey[700]),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF26647),
                                    minimumSize: const Size(220, 40),
                                  ),
                                  onPressed: _onListenPressed,
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
                        ],
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 160),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFF26647)),
                          ),
                        ),
                    ],
                  ),
                  Center(
                    child: SizedBox(
                      width: 250.w,
                      child: Text(
                        cardSummary,
                        style: TextStyle(
                          fontSize: 28.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: _canRecord && !_isLoading ? _recordAudio : null,
          backgroundColor: _isLoading
              ? const Color.fromARGB(37, 206, 204, 204) // 로딩 중 색상
              : _canRecord
                  ? (_isRecording
                      ? const Color(0xFF976841)
                      : const Color(0xFFF26647))
                  : const Color.fromARGB(37, 206, 204, 204),
          elevation: 0.0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(35))), // 조건 업데이트
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
