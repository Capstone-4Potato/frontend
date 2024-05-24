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

class WordLearningCard extends StatefulWidget {
  final int currentIndex;
  final List<int> cardIds;
  final List<String> contents;

  WordLearningCard({
    Key? key,
    required this.currentIndex,
    required this.cardIds,
    required this.contents,
  }) : super(key: key);

  @override
  State<WordLearningCard> createState() => _WordLearningCardState();
}

class _WordLearningCardState extends State<WordLearningCard> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;

  late String _filePathUserAudio;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    // final status = await Permission.microphone.request();
    // if (status != PermissionStatus.granted) {
    //   print("Microphone permission not granted");
    // }
    // await _recorder!.openAudioSession();
    // _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
    await Permission.microphone.request();
    await _recorder!.openAudioSession();
  }

  Future<void> _startRecording() async {
    // Stop the audio player if it is playing
    await TtsService.instance.stopAudioPlayer();

    // Add a small delay to ensure the audio session is released
    await Future.delayed(const Duration(milliseconds: 500));

    // Get temporary directory
    final directory = await getTemporaryDirectory();
    _filePathUserAudio = '${directory.path}/user_audio.wav';
    print("Recording to: $_filePathUserAudio");

    // Start recording
    try {
      await _recorder!.startRecorder(
        toFile: _filePathUserAudio,
        // codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
      });
      print("Recording started");
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      int currentCardId = widget.cardIds[widget.currentIndex];

      // Read file
      File audioFile = File(_filePathUserAudio);
      if (await audioFile.exists()) {
        List<int> fileBytes = await audioFile.readAsBytes();
        String base64userAudio = base64Encode(fileBytes);

        // Fetch correct audio from TtsService
        String? base64correctAudio = TtsService.instance.base64CorrectAudio;

        if (base64correctAudio != null) {
          FeedbackData? feedbackData = await getFeedback(
              currentCardId, base64userAudio, base64correctAudio);
          if (mounted && feedbackData != null) {
            showFeedbackDialog(context, feedbackData);
          }
        } else {
          print("Failed to fetch correct audio");
        }
      } else {
        print("Recorded file does not exist");
      }
    } catch (e) {
      print("Error stopping recording: $e");
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
        return Transform(
          transform: Matrix4.translationValues(0.0, 120, 0.0),
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
        builder: (context) => WordLearningCard(
          currentIndex: newIndex,
          cardIds: widget.cardIds,
          contents: widget.contents,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.70;
    double cardHeight = MediaQuery.of(context).size.height * 0.27;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
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
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF26647), width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // 발음 듣기 버튼 - correctAudio 들려주기
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26647),
                      minimumSize: Size(220, 40),
                    ),
                    onPressed: () {
                      TtsService.instance
                          .playCachedAudio(widget.cardIds[widget.currentIndex]);
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
