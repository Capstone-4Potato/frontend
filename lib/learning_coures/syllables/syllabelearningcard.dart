import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_application_1/tutorial/feedback_tutorial_screen1.dart';
import 'package:flutter_application_1/tutorial/feedback_tutorial_screen2.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/learning_coures/syllables/fetchimage.dart';
import 'package:flutter_application_1/learning_coures/syllables/syllablefeedbackui.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/permissionservice.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/widgets/recording_error_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyllableLearningCard extends StatefulWidget {
  int currentIndex;
  final List<int> cardIds;
  final List<String> texts;
  final List<String> translations;
  final List<String> engpronunciations;
  final List<String> explanations;
  final List<String> pictures;
  final List<bool> bookmarked;

  SyllableLearningCard({
    Key? key,
    required this.currentIndex,
    required this.cardIds,
    required this.texts,
    required this.translations,
    required this.engpronunciations,
    required this.explanations,
    required this.pictures,
    required this.bookmarked,
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
  final bool _isBluetoothConnected = false;

  bool _isLoading = false; // 피드백 로딩 중인지 여부
  Uint8List? _imageData; // 이미지를 저장할 변수
  bool _isImageLoading = true; // 이미지 로딩 중인지 여부

  late PageController pageController; // 페이지 컨트롤러 생성

  int feedbackTutorialStep = 1; // 피드백 튜토리얼 단계 상태

  final GlobalKey _listenButtonKey = GlobalKey();
  final GlobalKey _speakButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initialize(); // 초기 설정
    _loadImage(); // 이미지 로드
    _loadTutorialStatus(); // 튜토리얼 상태 로드
    pageController =
        PageController(initialPage: widget.currentIndex); // PageController 초기화
  }

  // SharedPreferences에서 튜토리얼 진행 상태를 불러오는 함수
  _loadTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      feedbackTutorialStep =
          prefs.getInt('feedbackTutorialStep') ?? 1; // 기본값은 1 (첫 번째 단계)
    });
  }

  // SharedPreferences에 튜토리얼 완료 상태 저장
  _completeTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('feedbackTutorialStep', 3); // 4로 설정하여 피드백 화면 튜토리얼 완료 표시
  }

  // 초기 설정 : 권한 요청 및 오디오 세션 열기
  Future<void> _initialize() async {
    await _permissionService.requestPermissions();
    await _audioRecorder.openAudioSession();
  }

  // 오디오 세션 설정
  Future<void> _setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    await session.setActive(true);
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
        final base64correctAudio = TtsService.instance.base64CorrectAudio;

        if (base64correctAudio != null) {
          try {
            // Set a timeout for the getFeedback call
            final feedbackData = await getFeedback(
              currentCardId,
              base64userAudio,
              base64correctAudio,
            ).timeout(
              const Duration(seconds: 6),
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
        } else {
          setState(() {
            _isLoading = false; // Stop loading
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

  // 사용자에게 올바른 발음 Listen 버튼 누르면 들려주기
  void _onListenPressed() async {
    //_setupAudioSession();
    await TtsService.instance
        .playCachedAudio(widget.cardIds[widget.currentIndex]);
    setState(() {
      _canRecord = true; // 녹음 가능 상태로 설정
      if (feedbackTutorialStep == 1) {
        feedbackTutorialStep = 2; // 1단계 끝나면 2단계로
      }
    });
  }

  // 피드백 다이얼로그 표시
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
        return SyllableFeedbackUI(
          feedbackData: feedbackData,
          recordedFilePath: _recordedFilePath,
          text: widget.texts[widget.currentIndex], // 카드 한글 발음
        );
      },
    );
  }

  // 오류 다이얼로그 표시
  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double height = MediaQuery.of(context).size.height / 852;
        final double width = MediaQuery.of(context).size.width / 393;

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
          page: HomeNav(),
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

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F5F5),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: bam,
                  onPressed: () {
                    Navigator.pop(
                        context, widget.bookmarked[widget.currentIndex]);
                  },
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  widget.bookmarked[widget.currentIndex]
                      ? Icons.bookmark
                      : Icons.bookmark_outline_sharp,
                  color: widget.bookmarked[widget.currentIndex]
                      ? const Color(0xFFF26647)
                      : Colors.grey[400],
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    // 북마크 상태를 토글
                    widget.bookmarked[widget.currentIndex] =
                        !widget.bookmarked[widget.currentIndex];
                  });
                  // 북마크 상태를 서버에 업데이트
                  updateBookmarkStatus(widget.cardIds[widget.currentIndex],
                      widget.bookmarked[widget.currentIndex]);
                },
              ),
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
                _canRecord = false;
              });
              _loadImage(); // 페이지 변경 시 이미지도 새로 로드
              // 새로 로드된 카드의 발음 오디오 파일 불러오기
              TtsService.fetchCorrectAudio(widget.cardIds[value]).then((_) {
                print('Audio fetched and saved successfully.');
              }).catchError((error) {
                print('Error fetching audio: $error');
              });
            },
            itemCount: widget.texts.length,
            itemBuilder: (context, index) {
              String currentContent = widget.texts[widget.currentIndex];
              String currentPronunciation =
                  widget.translations[widget.currentIndex];
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
                                  pageController.animateToPage(
                                    nextIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
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
                                "[$currentEngPronunciation]",
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
                              SizedBox(
                                height: 8.h,
                              ),
                              // 발음 듣기 버튼 - correctAudio 들려주기
                              ElevatedButton.icon(
                                key: feedbackTutorialStep == 1
                                    ? _listenButtonKey
                                    : null,
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
                          onPressed: widget.currentIndex <
                                  widget.texts.length - 1
                              ? () {
                                  int nextIndex = widget.currentIndex + 1;
                                  pageController.animateToPage(
                                    nextIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
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
                                  ? SizedBox(
                                      width: 300.w,
                                      height: 250.h,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        color: primary,
                                      )))
                                  : Image.memory(
                                      _imageData!,
                                      fit: BoxFit.contain,
                                      width: 300.w,
                                      height: 250.h,
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
            },
          ),
          // 녹음 시작/중지 버튼
          floatingActionButton: SizedBox(
            key: feedbackTutorialStep == 2 ? _speakButtonKey : null,
            width: 70.w,
            height: 70.h,
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
                  borderRadius:
                      BorderRadius.all(Radius.circular(35))), // 조건 업데이트
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 40,
                color: const Color.fromARGB(231, 255, 255, 255),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
        if (feedbackTutorialStep == 1)
          FeedbackTutorialScreen1(
            buttonKey: _listenButtonKey,
            onTap: () async {
              _onListenPressed();
            },
          ),
        if (feedbackTutorialStep == 2)
          FeedbackTutorialScreen2(
            buttonKey: _speakButtonKey,
            onTap: () {
              _canRecord && !_isLoading ? _recordAudio() : null;
              setState(() {
                feedbackTutorialStep = 3;
              });
              _completeTutorial();
            },
          ),
      ],
    );
  }
}
