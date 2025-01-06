import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/home/customsentences/bookmark.dart';
import 'package:flutter_application_1/home/customsentences/customfeedbackui.dart';
import 'package:flutter_application_1/home/customsentences/customtts.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/permissionservice.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/widgets/recording_error_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';

class CustomSentenceLearningCard extends StatefulWidget {
  int currentIndex;
  final List<int> cardIds;
  final List<String> texts;
  final List<String> pronunciations;
  final List<String> engpronunciations;

  CustomSentenceLearningCard({
    Key? key,
    required this.currentIndex,
    required this.cardIds,
    required this.texts,
    required this.pronunciations,
    required this.engpronunciations,
  }) : super(key: key);

  @override
  State<CustomSentenceLearningCard> createState() =>
      _CustomSentenceLearningCardState();
}

class _CustomSentenceLearningCardState
    extends State<CustomSentenceLearningCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final PermissionService _permissionService = PermissionService();
  bool _isRecording = false;
  bool _canRecord = true;
  late String _recordedFilePath;

  bool _isLoading = false;

  late PageController pageController; // 페이지 컨트롤러 생성

  @override
  void initState() {
    super.initState();
    _initialize();
    pageController =
        PageController(initialPage: widget.currentIndex); // PageController 초기화
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
          _recordedFilePath = path;
          _isLoading = true; // Start loading
        });
        final audioFile = File(path);
        final fileBytes = await audioFile.readAsBytes();
        final base64userAudio = base64Encode(fileBytes);
        final currentCardId = widget.cardIds[widget.currentIndex];
        final base64correctAudio = CustomTtsService.instance.base64CorrectAudio;

        try {
          // Set a timeout for the getFeedback call
          final feedbackData = await getCustomFeedback(
            currentCardId,
            base64userAudio,
            base64correctAudio!,
          ).timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw TimeoutException('Feedback request timed out');
            },
          );

          if (mounted && feedbackData != null) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            showFeedbackDialog(context, feedbackData);
          } else {
            setState(() {
              _isLoading = false; // Stop loading
            });
            showErrorDialog();
          }
        } catch (e) {
          setState(() {
            _isLoading = false; // Stop loading
          });
          if (e.toString() == 'Exception: ReRecordNeeded') {
            // Show the ReRecordNeeded dialog if the exception occurs
            showRecordLongerDialog(context);
          } else if (e is TimeoutException) {
            showTimeoutDialog(); // Show error dialog on timeout
          } else {
            showErrorDialog();
          }
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
    await CustomTtsService.fetchCorrectAudio(
            widget.cardIds[widget.currentIndex])
        .then((_) {
      print('Audio fetched and saved successfully.');
    }).catchError((error) {
      print('Error fetching audio: $error');
    });
    await CustomTtsService.instance
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
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform(
          transform: Matrix4.translationValues(0.0, 112, 0.0),
          child: Opacity(
            opacity: animation.value,
            child: CustomFeedbackUI(
              feedbackData: feedbackData,
              recordedFilePath: _recordedFilePath,
              text: widget.texts[widget.currentIndex],
            ),
          ),
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

  void showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecordingErrorDialog(
          text: "The server response timed out. Please try again.",
        );
      },
    );
  }

  // "좀 더 길게 녹음해주세요" 다이얼로그 표시 함수
  void showRecordLongerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecordingErrorDialog(
          text: "Please press the stop recording button a bit later.",
        );
      },
    );
  }

  void navigateToCard(int newIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CustomSentenceLearningCard(
          currentIndex: newIndex,
          cardIds: widget.cardIds,
          texts: widget.texts,
          pronunciations: widget.pronunciations,
          engpronunciations: widget.engpronunciations,
        ),
      ),
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
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.74;
    double cardHeight = MediaQuery.of(context).size.height * 0.32;

    String currentContent = widget.texts[widget.currentIndex];
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
      body: PageView.builder(
          controller: pageController,
          onPageChanged: (value) {
            setState(() {
              // currentIndex를 새로 갱신하여 카드 내용을 바꾸도록 설정
              widget.currentIndex = value;
            });
            CustomTtsService.fetchCorrectAudio(widget.cardIds[value]).then((_) {
              print('Audio fetched and saved successfully.');
            }).catchError((error) {
              print('Error fetching audio: $error');
            });
          },
          itemCount: widget.texts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: const Color(0XFFF26647),
                        iconSize: 20,
                        onPressed: widget.currentIndex > 0
                            ? () {
                                int nextIndex = widget.currentIndex - 1;
                                pageController.animateToPage(
                                  nextIndex,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color(0xFFF26647), width: 3.w),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              currentContent,
                              style: TextStyle(
                                fontSize: 24.h,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              currentEngPronunciation,
                              style: TextStyle(
                                fontSize: 18.h,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Text(
                              currentPronunciation,
                              style: TextStyle(
                                fontSize: 18.h,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 231, 156, 135),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 18.h,
                            ),
                            // 발음 듣기 버튼 - correctAudio 들려주기
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF26647),
                                minimumSize: const Size(240, 40),
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
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: const Color(0xFFF26647),
                        iconSize: 20,
                        onPressed: widget.currentIndex < widget.texts.length - 1
                            ? () {
                                int nextIndex = widget.currentIndex + 1;
                                pageController.animateToPage(
                                  nextIndex,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 160),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFF26647)),
                      ),
                    ),
                ],
              ),
            );
          }),
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
