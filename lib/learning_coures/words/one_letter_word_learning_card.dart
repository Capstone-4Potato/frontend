import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/new/functions/show_recording_error_dialog.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/learning_coures/syllables/fetchimage.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/home/home_nav.dart';
import 'package:flutter_application_1/new/services/token_manage.dart';
import 'package:flutter_application_1/widgets/exit_dialog.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/learning_coures/words/wordfeedbackui.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/permissionservice.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/new/widgets/recording_error_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

class OneLetterWordLearningCard extends StatefulWidget {
  int currentIndex;
  final List<int> cardIds;
  final List<String> texts;
  final List<String> translations;
  final List<String> engpronunciations;
  final List<String> explanations;
  final List<String> pictures;
  final List<bool> bookmarked;

  OneLetterWordLearningCard({
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
  State<OneLetterWordLearningCard> createState() =>
      _OneLetterWordLearningCardState();
}

class _OneLetterWordLearningCardState extends State<OneLetterWordLearningCard> {
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final PermissionService _permissionService = PermissionService();
  bool _isRecording = false;
  bool _canRecord = false;
  late String _recordedFilePath;

  bool _isLoading = false; // 피드백 로딩 중인지 여부
  Uint8List? _imageData; // 이미지를 저장할 변수
  bool _isImageLoading = true; // 이미지 로딩 중인지 여부

  late PageController pageController; // 페이지 컨트롤러 생성

  @override
  void initState() {
    super.initState();
    _initialize();
    fetchData();
    pageController =
        PageController(initialPage: widget.currentIndex); // PageController 초기화
  }

  Future<void> _initialize() async {
    await _audioPlayer.openPlayer();
    await _permissionService.requestPermissions();
    await _audioRecorder.openRecorder();
  }

  // 학습카드 리스트 API (음절, 단어, 문장)
  Future<void> fetchData() async {
    try {
      String? token = await getAccessToken();
      // Backend server URL
      var url =
          Uri.parse('$main_url/cards/${widget.cardIds[widget.currentIndex]}');

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
          widget.pictures[widget.currentIndex] = data['pictureUrl'] ?? '';
          widget.explanations[widget.currentIndex] = data['explanation'] ?? '';
          _loadImage();
          _isLoading = false;
        });
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
              widget.pictures[widget.currentIndex] = data['pictureUrl'] ?? '';
              widget.explanations[widget.currentIndex] =
                  data['explanation'] ?? '';
              _loadImage();
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return; // Return null if there's an error or unsuccessful fetch
  }

  // 이미지 로드
  Future<void> _loadImage() async {
    try {
      // currentIndex에 해당하는 이미지 URL이 비어있는 경우 처리
      if (widget.pictures[widget.currentIndex].isEmpty) {
        setState(() {
          _isImageLoading = false;
          _imageData = null; // 이미지 데이터를 null로 초기화
        });
        return; // 이미지를 불러오지 않음
      }

      setState(() {
        _isImageLoading = true;
      });

      // 이미지 데이터 가져오기
      final imageData = await fetchImage(widget.pictures[widget.currentIndex]);

      if (mounted) {
        // dispose() 이후 setState 방지
        setState(() {
          _isImageLoading = false;
          _imageData = imageData; // 이미지 데이터 갱신
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    }
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
              if (!mounted) return;
              showRecordingErrorDialog(context);
            }
          } catch (e) {
            setState(() {
              _isLoading = false; // Stop loading
            });
            if (e.toString() == 'Exception: ReRecordNeeded') {
              if (!mounted) return;
              showRecordingErrorDialog(context,
                  type: RecordingErrorType.tooShort);
            } else if (e is TimeoutException) {
              if (!mounted) return;
              showRecordingErrorDialog(context,
                  type: RecordingErrorType.timeout);
            } else {
              if (!mounted) return;
              showRecordingErrorDialog(context);
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
        toFile: 'audio_record_${widget.cardIds[widget.currentIndex]}.wav',
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _onListenPressed() async {
    await TtsService.instance
        .playCachedAudio(widget.cardIds[widget.currentIndex]);
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
          text: widget.texts[widget.currentIndex], // 카드 한글 발음
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
          page: HomeNav(),
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    _audioRecorder.closeRecorder();
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
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: bam,
              onPressed: () {
                Navigator.pop(
                  context,
                  widget.bookmarked[widget.currentIndex],
                );
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
              _isImageLoading = true;
            });
            // 새로 로드된 카드의 발음 오디오 파일 불러오기
            TtsService.fetchCorrectAudio(widget.cardIds[value]).then((_) {
              print('Audio fetched and saved successfully.');
            }).catchError((error) {
              print('Error fetching audio: $error');
            });
            fetchData();
          },
          itemCount: widget.texts.length,
          itemBuilder: (context, index) {
            String currentText = widget.texts[widget.currentIndex];
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
                              currentText,
                              style: const TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "[$currentEngPronunciation]",
                              style: TextStyle(
                                  fontSize: 22, color: Colors.grey[700]),
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
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: const Color(0xFFF26647),
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
                                : _imageData != null
                                    ? Image.memory(
                                        _imageData!,
                                        fit: BoxFit.contain,
                                        width: 300,
                                        height: 250,
                                      )
                                    : Container(),
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
                  if (_isLoading) // 피드백 로딩 중이면 Indicator 표시
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
