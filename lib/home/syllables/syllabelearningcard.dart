import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottomnavigationbartest.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/home/syllables/fetchimage.dart';
import 'package:flutter_application_1/home/syllables/syllablefeedbackui.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/permissionservice.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_sound/flutter_sound.dart';

class SyllableLearningCard extends StatefulWidget {
  int currentIndex;
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
  final AudioPlayer _audioPlayer = AudioPlayer(); // 오디오 재생기
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder(); // 오디오 녹음기
  final PermissionService _permissionService = PermissionService(); // 권한 서비스
  bool _isRecording = false; // 녹음 중인지 여부
  bool _canRecord = false; // 녹음 가능 여부
  late String _recordedFilePath; // 녹음된 파일 경로

  bool _isLoading = false; // 피드백 로딩 중인지 여부
  Uint8List? _imageData; // 이미지를 저장할 변수
  bool _isImageLoading = true; // 이미지 로딩 중인지 여부

  late PageController pageController; // 페이지 컨트롤러 생성

  @override
  void initState() {
    super.initState();
    _initialize(); // 초기 설정
    _loadImage(); // 이미지 로드
    pageController =
        PageController(initialPage: widget.currentIndex); // PageController 초기화
  }

  // 초기 설정 : 권한 요청 및 오디오 세션 열기
  Future<void> _initialize() async {
    await _permissionService.requestPermissions();
    await _audioRecorder.openAudioSession();
  }

  // 이미지 로드
  Future<void> _loadImage() async {
    try {
      setState(() {
        _isImageLoading = true;
      });
      final imageData = await fetchImage(
          widget.pictures[widget.currentIndex]); // 이미지 데이터 가져오기
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

  // 오디오 녹음 및 처리
  Future<void> _recordAudio() async {
    if (_isRecording) {
      final path = await _audioRecorder.stopRecorder(); // 녹음 중단
      if (path != null) {
        setState(() {
          _isRecording = false; // 녹음 상태 해체
          _recordedFilePath = path; // 녹음된 파일 경로 저장
          _isLoading = true; // 로딩 시작
        });

        final audioFile = File(path); // 녹음된 파일 불러오기
        final fileBytes = await audioFile.readAsBytes(); // 파일을 바이트로 읽기
        final base64userAudio = base64Encode(fileBytes); // Base64 인코딩
        final currentCardId = widget.cardIds[widget.currentIndex];
        final base64correctAudio = TtsService.instance.base64CorrectAudio;

        if (base64correctAudio != null) {
          final feedbackData = await getFeedback(currentCardId, base64userAudio,
              base64correctAudio); // 피드백 데이터 가져오기

          if (mounted && feedbackData != null) {
            setState(() {
              _isLoading = false; // 로딩 종료
            });
            showFeedbackDialog(context, feedbackData); // 피드백 다이얼로그 표시
          } else {
            setState(() {
              _isLoading = false; // 로딩 종료
              showErrorDialog(); // 오류 다이얼로그 표시
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
        _isRecording = true; // 녹음 상태 활성화
      });
    }
  }

  // 사용자에게 올바른 발음 Listen 버튼 누르면 들려주기
  void _onListenPressed() async {
    await TtsService.instance
        .playCachedAudio(widget.cardIds[widget.currentIndex]);
    setState(() {
      _canRecord = true; // 녹음 가능 상태로 설정
    });
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
            ),
          ),
        );
      },
    );
  }

  // 오류 다이얼로그 표시
  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Recording Error"),
          content: const Text(
            "Please try recording again.",
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFF26647), fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // 다른 카드로 이동
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

  // 학습 종료 확인 다이얼로그 표시
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
    _audioPlayer.dispose(); // 오디오 플레이어 정리
    _audioRecorder.closeAudioSession(); // 오디오 세션 닫기
    pageController.dispose();
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
      body: PageView.builder(
          controller: pageController,
          onPageChanged: (value) {
            setState(() {
              // currentIndex를 새로 갱신하여 카드 내용을 바꾸도록 설정
              widget.currentIndex = value;
            });
            _loadImage(); // 페이지 변경 시 이미지도 새로 로드
            // 새로 로드된 카드의 발음 오디오 파일 불러오기
            TtsService.fetchCorrectAudio(widget.cardIds[value]).then((_) {
              print('Audio fetched and saved successfully.');
            }).catchError((error) {
              print('Error fetching audio: $error');
            });
          },
          itemCount: widget.contents.length,
          itemBuilder: (context, index) {
            String currentContent = widget.contents[widget.currentIndex];
            String currentPronunciation =
                widget.pronunciations[widget.currentIndex];
            String currentEngPronunciation =
                widget.engpronunciations[widget.currentIndex];
            String currentExplanation =
                widget.explanations[widget.currentIndex];

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  // 이전 카드로 이동 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: const Color(0XFFF26647),
                        onPressed: widget.currentIndex > 0
                            ? () {
                                int nextIndex = widget.currentIndex - 1;
                                navigateToCard(nextIndex);
                                _loadImage();
                                TtsService.fetchCorrectAudio(
                                        widget.cardIds[nextIndex])
                                    .then((_) {
                                  print(
                                      'Audio fetched and saved successfully.');
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
                          border: Border.all(
                              color: const Color(0xFFF26647), width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              currentContent,
                              style: const TextStyle(
                                  fontSize: 38, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currentEngPronunciation,
                              style: TextStyle(
                                  fontSize: 24, color: Colors.grey[700]),
                            ),
                            Text(
                              currentPronunciation,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 231, 156, 135)),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            // 발음 듣기 버튼 - correctAudio 들려주기
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
                      // 다음 카드로 이동 버튼
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: const Color(0xFFF26647),
                        onPressed:
                            widget.currentIndex < widget.contents.length - 1
                                ? () {
                                    int nextIndex = widget.currentIndex + 1;
                                    navigateToCard(nextIndex); // 다음 카드로 이동
                                    _loadImage(); // 이미지 로드
                                    // 다음 카드에 해당하는 올바른 음성 데이터 불러오기
                                    TtsService.fetchCorrectAudio(
                                            widget.cardIds[nextIndex])
                                        .then((_) {
                                      print(
                                          'Audio fetched and saved successfully.');
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                        ),
                        child: Column(
                          children: <Widget>[
                            _isImageLoading // 이미지 로딩 중 표시
                                ? const SizedBox(
                                    width: 300,
                                    height: 250,
                                    child: Center(
                                        child: CircularProgressIndicator()))
                                : Image.memory(
                                    _imageData!,
                                    fit: BoxFit.contain,
                                    width: 300,
                                    height: 250,
                                  ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Text(
                                currentExplanation,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isLoading) // 피드백 로딩 중이면 로딩중 Indicator 표시
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
      // 녹음 시작/중지 버튼
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
