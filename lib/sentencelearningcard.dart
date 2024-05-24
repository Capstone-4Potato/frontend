import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/feedbackui.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:permission_handler/permission_handler.dart';

class SentenceLearningCard extends StatefulWidget {
  final int currentIndex;
  final List<int> cardIds;
  final List<String> contents;
  final List<String> pronunciations;
  final List<String> engpronunciations;

  SentenceLearningCard({
    Key? key,
    required this.currentIndex,
    required this.cardIds,
    required this.contents,
    required this.pronunciations,
    required this.engpronunciations,
  }) : super(key: key);

  @override
  State<SentenceLearningCard> createState() => _SentenceLearningCardState();
}

class _SentenceLearningCardState extends State<SentenceLearningCard> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  late String _filePathUserAudio;

  //bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      //throw RecordingPermissionException('Microphone permission not granted');
      print("Microphone permission not granted");
    }
    await _recorder!.openAudioSession();
    _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
// 캐시 디렉토리 경로 가져오기
    final directory = await getTemporaryDirectory();
    _filePathUserAudio = '${directory.path}/user_audio.wav';

    //print('녹음된 파일의 경로: $_filePathUserAudio'); // 변수 출력
    // if (_isPlaying = false) {
    //   // 레코더에 파일 경로 설정하여 녹음 시작
    //   await _recorder!.startRecorder(toFile: _filePathUserAudio);
    // }

    // // 레코더에 파일 경로 설정하여 녹음 시작
    await _recorder!.startRecorder(toFile: _filePathUserAudio);
    setState(() {
      _isRecording = true;
      //_isPlaying = false;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    int currentCardId = widget.cardIds[widget.currentIndex];

    // 파일 읽기
    File audioFile = File(_filePathUserAudio);
    List<int> fileBytes = await audioFile.readAsBytes();
    String base64userAudio = base64Encode(fileBytes);

    //getFeedback(currentCardId, base64userAudio, base64userAudio);
// Fetch correct audio data
    // String? base64correctAudio =
    //     await TtsService.fetchAndPlayCorrectAudio(currentCardId);

    //싱글톤 인스턴스에서 base64CorrectAudio 가져오기
    String? base64correctAudio = TtsService.instance.base64CorrectAudio;
    //print(base64correctAudio);
    //print(base64userAudio);

    if (base64correctAudio != null) {
      print("base64correctAudio는 널이 아님");
      FeedbackData? feedbackData =
          await getFeedback(currentCardId, base64userAudio, base64correctAudio);
      print(feedbackData);
      if (mounted && feedbackData != null) {
        showFeedbackDialog(context, feedbackData);
      }
    } else {
      // Handle error: correct audio could not be fetched
      print("피드백받기실패");
    }
  }

  @override
  void dispose() {
    _recorder!.closeAudioSession();
    _recorder = null;
    super.dispose();
  }

  void showFeedbackDialog(BuildContext context, FeedbackData feedbackData) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Feedback",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        //final curvedValue = Curves.easeInOut.transform(animation.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, 112, 0.0),
          child: Opacity(
            opacity: animation.value,
            child: FeedbackUI(feedbackData: feedbackData),
          ),
        );
      },
    );
  }

  void navigateToCard(int newIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SentenceLearningCard(
          currentIndex: newIndex,
          cardIds: widget.cardIds,
          contents: widget.contents,
          pronunciations: widget.pronunciations,
          engpronunciations: widget.engpronunciations,
        ),
      ),
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.75;
    double cardHeight = MediaQuery.of(context).size.height * 0.28;

    String currentContent = widget.contents[widget.currentIndex];
    String currentPronunciation = widget.pronunciations[widget.currentIndex];
    String currentEngPronunciation =
        widget.engpronunciations[widget.currentIndex];

    return Scaffold(
      appBar: AppBar(
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
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Color(0XFFF26647),
              iconSize: 20,
              onPressed: widget.currentIndex > 0
                  ? () {
                      int nextIndex = widget.currentIndex - 1;
                      navigateToCard(nextIndex);
                      TtsService.fetchCorrectAudio(widget.cardIds[nextIndex])
                          .then((_) {
                        print('Audio fetched and saved successfully.');
                      }).catchError((error) {
                        print('Error fetching audio: $error');
                      });
                    }
                  : null,
            ),
            Container(
              width: cardWidth,
              height: cardHeight,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF26647), width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    currentContent,
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  // const SizedBox(
                  //   height: 3,
                  // ),
                  Text(
                    currentPronunciation,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  Text(
                    currentEngPronunciation,
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // 발음 듣기 버튼 - correctAudio 들려주기
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26647),
                      minimumSize: Size(240, 40),
                    ),
                    onPressed: () {
                      // if (TtsService.instance.base64CorrectAudio != null) {
                      //   // If audio is already fetched, play it immediately
                      TtsService.instance
                          .playCachedAudio(widget.cardIds[widget.currentIndex]);

                      // _isPlaying = true;
                      // } else {
                      //   TtsService.fetchCorrectAudio(
                      //           widget.cardIds[widget.currentIndex])
                      //       .then((_) {
                      //     TtsService.instance.playCachedAudio();
                      //   });
                      // }
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
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              color: const Color(0xFFF26647),
              iconSize: 20,
              onPressed: widget.currentIndex < widget.contents.length - 1
                  ? () {
                      int nextIndex = widget.currentIndex + 1;
                      navigateToCard(nextIndex);
                      TtsService.fetchCorrectAudio(widget.cardIds[nextIndex])
                          .then((_) {
                        print('Audio fetched and saved successfully.');
                      }).catchError((error) {
                        print('Error fetching audio: $error');
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onLongPress: _startRecording,
        onLongPressUp: _stopRecording,
        child: Container(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: () {},
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 40,
              color: const Color.fromARGB(231, 255, 255, 255),
            ),
            backgroundColor:
                _isRecording ? Color(0xFF976841) : Color(0xFFF26647),
            elevation: 0.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(35))),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
