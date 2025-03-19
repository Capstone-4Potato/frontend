import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/learning_coures/syllables/syllabelearningcard.dart';
import 'package:flutter_application_1/new/models/app_colors.dart';
import 'package:flutter_application_1/new/widgets/feedback_widgets.dart';
import 'package:flutter_application_1/new/widgets/try_again_button.dart';
import 'package:flutter_application_1/new/widgets/user_score_panel.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/widgets/audio_graph.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';

/// 피드백 Dialog창
class FeedbackDialog extends StatefulWidget {
  final FeedbackData feedbackData; // 피드백 결과 데이터
  final String recordedFilePath; // 사용자 음성 녹음 파일 경로
  final String correctText; // 올바른 발음
  // 필수 매개변수로 피드백 데이터와 녹음된 파일 경로를 받는다

  const FeedbackDialog({
    super.key,
    required this.feedbackData,
    required this.recordedFilePath,
    required this.correctText,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  late final PlayerController _userPlayerController;
  late final PlayerController _correctPlayerController;
  bool _isUserPlaying = false;
  bool _isCorrectPlaying = false;

  @override
  void initState() {
    super.initState();
    _initPlayerController();
    _audioPlayer.openPlayer();
  }

  // waveForm 컨트롤러 초기화
  void _initPlayerController() {
    _userPlayerController = PlayerController();
    _correctPlayerController = PlayerController();
    _preparePlayer();
  }

  Future<void> _preparePlayer() async {
    try {
      // Initialize user recording controller
      await _userPlayerController.preparePlayer(
        path: widget.recordedFilePath,
        noOfSamples: 50, // 웨이브폼 샘플 수
      );

      // Get path for correct audio and initialize its controller
      String correctAudioPath =
          await TtsService.getCorrectAudioPath(widget.feedbackData.cardId);
      File correctAudioFile = File(correctAudioPath);

      // Check if the correct audio file exists
      if (await correctAudioFile.exists()) {
        await _correctPlayerController.preparePlayer(
          path: correctAudioPath,
          noOfSamples: 50, // 웨이브폼 샘플 수
        );
      } else {
        // If the file doesn't exist yet, fetch it first
        await TtsService.fetchCorrectAudio(widget.feedbackData.cardId);
        // Then initialize the controller
        await _correctPlayerController.preparePlayer(
          path: correctAudioPath,
          noOfSamples: 50,
        );
      }
    } catch (e) {
      debugPrint('플레이어 초기화 오류: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    _userPlayerController.dispose();
    _correctPlayerController.dispose();
    super.dispose();
  }

  /// 알맞은 발음 재생 함수
  Future<void> _playCorrectRecording() async {
    if (_isCorrectPlaying) {
      await _correctPlayerController.pausePlayer();
    } else {
      // Get path for correct audio and initialize its controller
      String correctAudioPath =
          await TtsService.getCorrectAudioPath(widget.feedbackData.cardId);

      await _audioPlayer.startPlayer(
          fromURI: correctAudioPath, codec: Codec.pcm16WAV);
    }

    setState(() {
      _isCorrectPlaying = !_isCorrectPlaying;
    });
  }

  /// 사용자 음성 재생 함수
  Future<void> _playUserRecording() async {
    if (_isUserPlaying) {
      await _userPlayerController.pausePlayer();
    } else {
      await _audioPlayer.startPlayer(
          fromURI: widget.recordedFilePath, codec: Codec.pcm16WAV);
    }

    setState(() {
      _isUserPlaying = !_isUserPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
// recommendCard의 key값 가져오기
    String recommendCardKey = widget.feedbackData.getRecommendCardKey();

    return Dialog(
      insetPadding: EdgeInsets.only(
          right: 38.0.w, left: 38.0.w, top: 53.0.h, bottom: 26.0.h),
      backgroundColor: Colors.transparent,
      child: Column(
        children: [
          // 피드백 창
          Container(
            decoration: BoxDecoration(
                color: AppColors.dialogBackground_001,
                borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding:
                  EdgeInsets.only(right: 21.0.w, left: 21.0.w, bottom: 30.0.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 점수에 따른 캐릭터 도장
                      FeedbackStamp(
                        userScore: widget.feedbackData.userScore,
                        recommendCardKey: recommendCardKey,
                      ),
                      // 점수 패널
                      UserScorePanel(userScore: widget.feedbackData.userScore),
                    ],
                  ),
                  // 한국어 발음 패널
                  Container(
                    margin: EdgeInsets.only(top: 10.0.h, bottom: 25.0.h),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: AppColors.dialogBackground_000,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.0.w, right: 18.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0.h),
                            // 사용자 발음 텍스트와 잘못된 부분을 표시하는 텍스트 위젯
                            child: FeedbackText(
                              feedbackData: widget.feedbackData,
                              correctText: widget.correctText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Amplitude 그래프
                  Container(
                    margin: EdgeInsets.only(
                        right: 18.0.w, left: 18.0.w, bottom: 26.0.h),
                    height: 195.0.h,
                    child: Stack(
                      children: [
                        AudioGraphWidget(
                          feedbackData: widget.feedbackData,
                        ),
                        Positioned(
                          right: 0,
                          child: Wrap(
                            spacing: 2.0.h,
                            direction: Axis.vertical,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: const [
                              AudioGraphLabel(
                                labelColor: AppColors.orange_000,
                                labelText: "Correct",
                              ),
                              AudioGraphLabel(
                                labelColor: AppColors.black,
                                labelText: "User",
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // 취약 음소 표시
                  FeedbackResultContainer(
                    title: 'Practice',
                    content: SizedBox(
                      width: 180.0.w,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          children: [
                            for (int i = 0;
                                i <
                                    widget.feedbackData.recommendCard.entries
                                        .length;
                                i += 2)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int j = i; j < i + 2; j++)
                                    if (j <
                                        widget.feedbackData.recommendCard
                                            .entries.length)
                                      GestureDetector(
                                        onTap: () {
                                          final recommendCardKey = widget
                                              .feedbackData
                                              .recommendCard
                                              .entries
                                              .elementAt(j)
                                              .key;
                                          final recommendCardData = widget
                                              .feedbackData
                                              .recommendCard
                                              .entries
                                              .elementAt(j)
                                              .value;
                                          recommendCardKey == "Perfect" ||
                                                  recommendCardKey ==
                                                      "Try Again"
                                              ? null
                                              : Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SyllableLearningCard(
                                                      currentIndex: 0,
                                                      cardIds: [
                                                        recommendCardData[
                                                                'id'] ??
                                                            0
                                                      ],
                                                      texts: [
                                                        recommendCardData[
                                                                'text'] ??
                                                            ''
                                                      ],
                                                      translations: [
                                                        recommendCardData[
                                                                'cardTranslation'] ??
                                                            ''
                                                      ],
                                                      engpronunciations: [
                                                        recommendCardData[
                                                                'cardPronunciation'] ??
                                                            ''
                                                      ],
                                                      explanations: [
                                                        recommendCardData[
                                                                'explanation'] ??
                                                            ''
                                                      ],
                                                      pictures: [
                                                        recommendCardData[
                                                                'pictureUrl'] ??
                                                            ''
                                                      ],
                                                      bookmarked: [
                                                        recommendCardData[
                                                                'bookmark'] ??
                                                            false
                                                      ],
                                                    ),
                                                  ),
                                                ).then((updatedBookmark) {
                                                  if (updatedBookmark != null) {
                                                    setState(() {
                                                      recommendCardData[
                                                              'bookmark'] =
                                                          updatedBookmark;
                                                    });
                                                  }
                                                });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 3.h, horizontal: 4.w),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: Text(
                                            widget.feedbackData.recommendCard
                                                .entries
                                                .elementAt(j)
                                                .key,
                                            style: TextStyle(
                                              color: const Color(0xFF15B931),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Pretendard',
                                              fontSize: 15.h,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 올바른 음성
                  FeedbackResultContainer(
                    title: 'Correct',
                    content: FeedbackWaveformContainer(
                      buttonBackgroundColor: AppColors.orange_000,
                      containerBackgroundColor: AppColors.orange_004,
                      playerController: _correctPlayerController,
                      // Replace the existing onPressed handler for correct audio
                      onPressed: _playCorrectRecording,
                    ),
                  ),
                  // 사용자 음성
                  FeedbackResultContainer(
                    title: 'User',
                    content: FeedbackWaveformContainer(
                      buttonBackgroundColor: AppColors.black,
                      containerBackgroundColor: AppColors.white_000,
                      playerController: _userPlayerController,
                      onPressed: _playUserRecording,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 공백
          Container(
            height: 20.0,
          ),
          // try again 버튼
          TryAgainButton(
            userScore: widget.feedbackData.userScore,
          ),
        ],
      ),
    );
  }
}
