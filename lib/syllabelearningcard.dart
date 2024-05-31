import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/feedbackui.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/permissionservice.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_sound/flutter_sound.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final PermissionService _permissionService = PermissionService();
  bool _isRecording = false;
  bool _canRecord = false;
  late String _recordedFilePath;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _permissionService.requestPermissions();
    await _audioRecorder.openAudioSession();
  }

  Future<void> _recordAudio() async {
    if (_isRecording) {
      final path = await _audioRecorder.stopRecorder();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _canRecord = false;
          _recordedFilePath = path;
          _isLoading = true; // 로딩 시작
        });

        final audioFile = File(path);
        final fileBytes = await audioFile.readAsBytes();
        final base64userAudio = base64Encode(fileBytes);
        final currentCardId = widget.cardIds[widget.currentIndex];
        final base64correctAudio = TtsService.instance.base64CorrectAudio;

        if (base64correctAudio != null) {
          final feedbackData = await getFeedback(
              currentCardId, base64userAudio, base64correctAudio);

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
    await TtsService.fetchCorrectAudio(widget.cardIds[widget.currentIndex]);
    await TtsService.instance
        .playCachedAudio(widget.cardIds[widget.currentIndex]);
    setState(() {
      _canRecord = true;
    });
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
            child: FeedbackUI(
              feedbackData: feedbackData,
              recordedFilePath: _recordedFilePath,
            ),
          ),
        );
      },
    );
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      //barrierDismissible: false, // 사용자가 다이얼로그 바깥을 터치하여 닫지 못하게 함
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Recording Error"),
          content: Text(
            "Please try recording again.",
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text(
                'OK',
                style: TextStyle(color: Color(0xFFF26647), fontSize: 16),
              ),
            ),
          ],
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
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.closeAudioSession();
    super.dispose();
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
                        height: 8,
                      ),
                      // 발음 듣기 버튼 - correctAudio 들려주기
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF26647),
                          minimumSize: Size(220, 40),
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
            if (!_isLoading)
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.82,
                  height: MediaQuery.of(context).size.height * 0.54,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                  ),
                  child: Column(
                    children: <Widget>[
                      ImageDisplay(base64Image: currentPictureBase64),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Text(
                          currentExplanation,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 160),
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(const Color(0xFFF26647)),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          //onPressed: _canRecord ? _recordAudio : null,
          onPressed: _canRecord && !_isLoading ? _recordAudio : null, // 조건 업데이트
          child: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            size: 40,
            color: const Color.fromARGB(231, 255, 255, 255),
          ),
          backgroundColor: _isLoading
              ? const Color.fromARGB(37, 206, 204, 204) // 로딩 중 색상
              : _canRecord
                  ? (_isRecording ? Color(0xFF976841) : Color(0xFFF26647))
                  : const Color.fromARGB(37, 206, 204, 204),
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
      height: 250,
    );
  }
}
