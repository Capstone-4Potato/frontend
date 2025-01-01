import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/home/syllables/syllabelearningcard.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_application_1/widgets/audio_graph.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

/// 한글자 음절 피드백 창
class TodayFeedbackUI extends StatefulWidget {
  final FeedbackData feedbackData;
  final String recordedFilePath;
  String text; // 올바른 발음

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

  // base64 문자열을 디코딩하고 임시 파일에 저장 후 오디오 재생
  Future<void> playAudio(String base64AudioString) async {
    try {
      // base64 문자열을 디코딩하여 Uint8List로 변환
      Uint8List audioBytes = base64Decode(base64AudioString);

      // 임시 디렉터리 경로를 가져옴
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/temp_audio.mp3'; // 파일명 설정

      // 파일로 저장
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(audioBytes);

      // 저장된 파일 재생
      await _audioPlayer.play(DeviceFileSource(tempPath));
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // recommendCard의 key값 가져오기
    String recommendCardKey = widget.feedbackData.getRecommendCardKey();

    return widget.feedbackData.userScore == 100 // 100점일 떄
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
                            // 나가기 버튼
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
                                          SizedBox(
                                            width: 155.w,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
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
                                                    color:
                                                        const Color(0xFFF1BEA7),
                                                    shape: BoxShape
                                                        .circle, // 원형 테두리
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFE87A49), // 테두리 색상
                                                      width: 4.0.w, // 테두리 두께
                                                    ),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.volume_up),
                                                    color: Colors.black,
                                                    iconSize: 20.0.w,
                                                    onPressed: () {
                                                      TtsService.instance
                                                          .playCachedAudio(
                                                              widget
                                                                  .feedbackData
                                                                  .cardId);
                                                    },
                                                  ),
                                                ),
                                              ],
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
                                          SizedBox(
                                            width: 155.w,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  widget.feedbackData.userText
                                                          .isEmpty
                                                      ? widget.text
                                                      : widget.feedbackData
                                                          .userText,
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
                                                    color:
                                                        const Color(0xFFEBEBEB),
                                                    shape: BoxShape
                                                        .circle, // 원형 테두리
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFBEBDB8), // 테두리 색상
                                                      width: 4.0.w, // 테두리 두께
                                                    ),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.volume_up),
                                                    color: Colors.black,
                                                    iconSize: 20.0.w,
                                                    onPressed: () {
                                                      _playUserRecording();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16.h,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: Text(
                                            "👍🏼 $recommendCardKey 👍🏼",
                                            style: TextStyle(
                                              color: const Color(0xFF15B931),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Pretendard',
                                              fontSize: 28.h,
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
        : recommendCardKey == "Try Again" // 4글자 이상 틀린 경우
            ? DraggableScrollableSheet(
                // 드래그 시트
                initialChildSize: (652 / 853).h,
                minChildSize: (400 / 665).h,
                maxChildSize: (652 / 853).h,
                shouldCloseOnMinExtent: true,
                expand: true,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                            // 닫기 버튼
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
                                // 점수 표시
                                Text.rich(
                                  TextSpan(
                                    text: widget.feedbackData.userScore
                                        .toString(),
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
                                // 올바른 발음
                                Container(
                                  width: 340.w,
                                  height: 60.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
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
                                      SizedBox(
                                        width: 185.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              widget.text,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 32.h,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Pretendard',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            Container(
                                              width: 42.w,
                                              height: 42.h,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1BEA7),
                                                shape:
                                                    BoxShape.circle, // 원형 테두리
                                                border: Border.all(
                                                  color: const Color(
                                                      0xFFE87A49), // 테두리 색상
                                                  width: 4.0.w, // 테두리 두께
                                                ),
                                              ),
                                              child: IconButton(
                                                icon:
                                                    const Icon(Icons.volume_up),
                                                color: Colors.black,
                                                iconSize: 20.0.w,
                                                onPressed: () {
                                                  TtsService.instance
                                                      .playCachedAudio(widget
                                                          .feedbackData.cardId);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 9.h,
                                ),
                                // 유저 발음
                                Container(
                                  width: 340.w,
                                  height: 60.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
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
                                      SizedBox(
                                        width: 185.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 150.w,
                                              child:
                                                  // 사용자 발음 텍스트와 잘못된 부분을 표시하는 텍스트 위젯
                                                  buildTextSpans(
                                                widget.feedbackData.userText,
                                                widget.feedbackData
                                                    .mistakenIndexes,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            Container(
                                              width: 42.w,
                                              height: 42.h,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEBEBEB),
                                                shape:
                                                    BoxShape.circle, // 원형 테두리
                                                border: Border.all(
                                                  color: const Color(
                                                      0xFFBEBDB8), // 테두리 색상
                                                  width: 4.0.w, // 테두리 두께
                                                ),
                                              ),
                                              child: IconButton(
                                                icon:
                                                    const Icon(Icons.volume_up),
                                                color: Colors.black,
                                                iconSize: 20.0.w,
                                                onPressed: () {
                                                  _playUserRecording();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 16.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Text(
                                        "🥺 $recommendCardKey 🥺",
                                        style: TextStyle(
                                          color: const Color(0xFF15B931),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Pretendard',
                                          fontSize: 28.h,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 16.h,
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
              )
            : DraggableScrollableSheet(
                // 100점이 아닌 경우
                // 드래그 시트
                initialChildSize: (652 / 853).h,
                minChildSize: (400 / 665).h,
                maxChildSize: (652 / 853).h,
                shouldCloseOnMinExtent: true,
                expand: true,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                                    text: widget.feedbackData.userScore
                                        .toString(),
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
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
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
                                      SizedBox(
                                        width: 155.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
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
                                                shape:
                                                    BoxShape.circle, // 원형 테두리
                                                border: Border.all(
                                                  color: const Color(
                                                      0xFFE87A49), // 테두리 색상
                                                  width: 4.0.w, // 테두리 두께
                                                ),
                                              ),
                                              child: IconButton(
                                                icon:
                                                    const Icon(Icons.volume_up),
                                                color: Colors.black,
                                                iconSize: 20.0.w,
                                                onPressed: () async {
                                                  playAudio(widget.feedbackData
                                                      .correctAudioText);
                                                },
                                              ),
                                            ),
                                          ],
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
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
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
                                      SizedBox(
                                        width: 155.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            widget.feedbackData.userText
                                                        .length ==
                                                    widget.text.length
                                                ?
                                                // 사용자 발음 텍스트와 잘못된 부분을 표시하는 텍스트 위젯
                                                buildTextSpans(
                                                    widget
                                                        .feedbackData.userText,
                                                    widget.feedbackData
                                                        .mistakenIndexes,
                                                  )
                                                : buildTextSpansOmit(
                                                    // 발음 안된 글자가 있을 때
                                                    widget.text,
                                                    widget
                                                        .feedbackData.userText),
                                            Container(
                                              width: 42.w,
                                              height: 42.h,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEBEBEB),
                                                shape:
                                                    BoxShape.circle, // 원형 테두리
                                                border: Border.all(
                                                  color: const Color(
                                                      0xFFBEBDB8), // 테두리 색상
                                                  width: 4.0.w, // 테두리 두께
                                                ),
                                              ),
                                              child: IconButton(
                                                icon:
                                                    const Icon(Icons.volume_up),
                                                color: Colors.black,
                                                iconSize: 20.0.w,
                                                onPressed: () {
                                                  _playUserRecording();
                                                },
                                              ),
                                            ),
                                          ],
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
                                    Text(
                                      'Practice',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.h,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 28.w,
                                    ),
                                    Column(
                                      children: [
                                        for (int i = 0;
                                            i <
                                                widget
                                                    .feedbackData
                                                    .recommendCard
                                                    .entries
                                                    .length;
                                            i += 2)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              for (int j = i; j < i + 2; j++)
                                                if (j <
                                                    widget
                                                        .feedbackData
                                                        .recommendCard
                                                        .entries
                                                        .length)
                                                  GestureDetector(
                                                    onTap: () {
                                                      final recommendCardKey =
                                                          widget
                                                              .feedbackData
                                                              .recommendCard
                                                              .entries
                                                              .elementAt(j)
                                                              .key;
                                                      final recommendCardData =
                                                          widget
                                                              .feedbackData
                                                              .recommendCard
                                                              .entries
                                                              .elementAt(j)
                                                              .value;

                                                      Navigator.push(
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
                                                        if (updatedBookmark !=
                                                            null) {
                                                          setState(() {
                                                            recommendCardData[
                                                                    'bookmark'] =
                                                                updatedBookmark;
                                                          });
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 3.h,
                                                              horizontal: 4.w),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12.w,
                                                              vertical: 3.h),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.r),
                                                      ),
                                                      child: Text(
                                                        widget
                                                            .feedbackData
                                                            .recommendCard
                                                            .entries
                                                            .elementAt(j)
                                                            .key,
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF15B931),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily:
                                                              'Pretendard',
                                                          fontSize: 15.h,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            ],
                                          ),
                                      ],
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
