import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/test_screen.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/widgets/audio_graph.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 한글자 음절 피드백 창
class TodayFeedbackUI extends StatefulWidget {
  final FeedbackData feedbackData;
  final String recordedFilePath;
  String text;

  TodayFeedbackUI({
    super.key,
    required this.feedbackData,
    required this.recordedFilePath,
    required this.text,
  });

  @override
  State<TodayFeedbackUI> createState() => _TodayFeedbackUIState();
}

class _TodayFeedbackUIState extends State<TodayFeedbackUI> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playUserRecording() async {
    await _audioPlayer
        .play(DeviceFileSource(widget.recordedFilePath, mimeType: "audio/mp3"))
        .onError((error, stackTrace) =>
            throw Exception("Failed to play Local audio $error"));
  }

  @override
  Widget build(BuildContext context) {
    // recommendCard의 key값 가져오기
    String recommendCardKey = widget.feedbackData.getRecommendCardKey();

    return widget.feedbackData.userScore == 100
        ? DraggableScrollableSheet(
            // 드래그 시트
            initialChildSize: (734 / 853).h,
            minChildSize: (700 / 853).h,
            maxChildSize: (734 / 853).h,
            shouldCloseOnMinExtent: true,
            expand: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return Material(
                type: MaterialType.transparency,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCEDFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.0.h),
                          child: Text.rich(
                            TextSpan(
                              text: widget.feedbackData.userScore.toString(),
                              style: TextStyle(
                                fontSize: 74.h,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Pretendard',
                                color: const Color(0xFFF26647),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '%',
                                  style: TextStyle(
                                    fontSize: 24.h,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Pretendard',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 70.h,
                        child: Image.asset(
                          'assets/image/feedback_background.png',
                          width: 395.w,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 16.w,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 200.0.h),
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Container(
                                      width: 340.w,
                                      height: 60.h,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Correct',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.h,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            widget.text,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 32.h,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 9.h,
                                    ),
                                    Container(
                                      width: 340.w,
                                      height: 60.h,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'User',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.h,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            widget.text,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 32.h,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          //height: 28.h,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: Text(
                                            recommendCardKey == "Perfect"
                                                ? "👍🏼 $recommendCardKey 👍🏼"
                                                : "🥺 $recommendCardKey 🥺",
                                            style: TextStyle(
                                              color: const Color(0xFF15B931),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Pretendard',
                                              fontSize: 32.h,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    AudioGraphWidget(
                                      feedbackData: widget.feedbackData,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : DraggableScrollableSheet(
            // 드래그 시트
            initialChildSize: (652 / 853).h,
            minChildSize: (400 / 665).h,
            maxChildSize: (652 / 853).h,
            shouldCloseOnMinExtent: true,
            expand: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return Material(
                type: MaterialType.transparency,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 16.w,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                text: widget.feedbackData.userScore.toString(),
                                style: TextStyle(
                                  fontSize: 74.h,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pretendard',
                                  color: const Color(0xFFF26647),
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '%',
                                    style: TextStyle(
                                      fontSize: 24.h,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Pretendard',
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Container(
                              width: 340.w,
                              height: 60.h,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Correct',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.h,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    widget.text,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 32.h,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  Container(
                                    width: 42.w,
                                    height: 42.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1BEA7),
                                      shape: BoxShape.circle, // 원형 테두리
                                      border: Border.all(
                                        color:
                                            const Color(0xFFE87A49), // 테두리 색상
                                        width: 4.0.w, // 테두리 두께
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.volume_up),
                                      color: Colors.black,
                                      iconSize: 20.0.w,
                                      onPressed: () {
                                        TtsService.instance.playCachedAudio(
                                            widget.feedbackData.cardId);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 9.h,
                            ),
                            Container(
                              width: 340.w,
                              height: 60.h,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'User',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.h,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    widget.text,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 32.h,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                  Container(
                                    width: 42.w,
                                    height: 42.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEBEBEB),
                                      shape: BoxShape.circle, // 원형 테두리
                                      border: Border.all(
                                        color:
                                            const Color(0xFFBEBDB8), // 테두리 색상
                                        width: 4.0.w, // 테두리 두께
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.volume_up),
                                      color: Colors.black,
                                      iconSize: 20.0.w,
                                      onPressed: () {
                                        _playUserRecording;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 32.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  //height: 28.h,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    recommendCardKey == "Perfect"
                                        ? "👍🏼 $recommendCardKey 👍🏼"
                                        : "🥺 $recommendCardKey 🥺",
                                    style: TextStyle(
                                      color: const Color(0xFF15B931),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Pretendard',
                                      fontSize: 32.h,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AudioGraphWidget(
                              feedbackData: widget.feedbackData,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
