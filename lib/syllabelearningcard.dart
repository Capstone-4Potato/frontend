import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
//import 'package:flutter_application_1/audioplayerutil.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/feedbackui.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SyllableLearningCard extends StatefulWidget {
  final int currentIndex;
  final List<int> cardIds;
  final List<String> contents;
  final List<String> pronunciations;
  final List<String> engpronunciations;
  final List<String> explanations;
  final List<String> pictures;

  SyllableLearningCard({
    Key? key,
    required this.currentIndex,
    required this.cardIds,
    required this.contents,
    required this.pronunciations,
    required this.engpronunciations,
    required this.explanations,
    required this.pictures,
  }) : super(key: key);

  @override
  State<SyllableLearningCard> createState() => _SyllableLearningCardState();
}

class _SyllableLearningCardState extends State<SyllableLearningCard> {
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
      // print("Recording stopped");

      int currentCardId = widget.cardIds[widget.currentIndex];

      // Read file
      File audioFile = File(_filePathUserAudio);
      if (await audioFile.exists()) {
        List<int> fileBytes = await audioFile.readAsBytes();
        String base64userAudio = base64Encode(fileBytes);

        // Log the length of the recorded file
        print("Recorded file length: ${fileBytes.length}");

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
        builder: (context) => SyllableLearningCard(
          currentIndex: newIndex,
          cardIds: widget.cardIds,
          contents: widget.contents,
          pronunciations: widget.pronunciations,
          engpronunciations: widget.engpronunciations,
          explanations: widget.explanations,
          pictures: widget.pictures,
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
                // Navigator.of(context).pop();
                // Navigator.of(context).pop(); // Exit the learning screen
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainPage(initialIndex: 0)),
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
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.70;
    double cardHeight = MediaQuery.of(context).size.height * 0.27;

    String currentContent = widget.contents[widget.currentIndex];
    String currentPronunciation = widget.pronunciations[widget.currentIndex];
    String currentEngPronunciation =
        widget.engpronunciations[widget.currentIndex];

    String currentExplanation = widget.explanations[widget.currentIndex];
    String currentPictureBase64 = widget.pictures[widget.currentIndex];

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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Color(0XFFF26647),
                  onPressed: widget.currentIndex > 0
                      ? () {
                          int nextIndex = widget.currentIndex - 1;
                          navigateToCard(nextIndex);
                          TtsService.fetchCorrectAudio(
                                  widget.cardIds[nextIndex])
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
                    border:
                        Border.all(color: const Color(0xFFF26647), width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        currentContent,
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentPronunciation,
                        style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                      ),
                      Text(
                        currentEngPronunciation,
                        style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      // 발음 듣기 버튼 - correctAudio 들려주기
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF26647),
                          minimumSize: Size(220, 40),
                        ),
                        onPressed: () {
                          TtsService.instance.playCachedAudio(
                              widget.cardIds[widget.currentIndex]);
                          //      String filePath = await AudioPlayerUtil
                          //     .fetchAndSaveBase64CorrectAudio(
                          //         widget.cardIds[widget.currentIndex]);
                          // AudioPlayerUtil.playLocalFile(filePath);
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
                          TtsService.fetchCorrectAudio(
                                  widget.cardIds[nextIndex])
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
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.82,
                height: MediaQuery.of(context).size.height * 0.54,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  //border: Border.all(color: const Color(0xFFF26647), width: 3),
                  //borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 0, 12, 0),
                      child: Text(
                        currentExplanation,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Image.memory(
                    //   base64Decode(currentPictureBase64),
                    //   width: 300,
                    //   height: 280,
                    // ),
                    ImageDisplay(base64Image: currentPictureBase64),
                  ],
                ),
              ),
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

class ImageDisplay extends StatefulWidget {
  final String base64Image;

  const ImageDisplay({Key? key, required this.base64Image}) : super(key: key);

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  late dynamic imageBytes;

  @override
  void initState() {
    super.initState();
    imageBytes = base64Decode(widget.base64Image);
  }

  @override
  void didUpdateWidget(covariant ImageDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64Image != widget.base64Image) {
      setState(() {
        imageBytes = base64Decode(widget.base64Image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      imageBytes,
      fit: BoxFit.contain,
      width: 300,
      height: 280,
    );
  }
}
