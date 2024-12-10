import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/customsentences/customtts.dart';
import 'package:flutter_application_1/home/customsentences/feedbackusertext.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/function.dart';

class CustomFeedback extends StatefulWidget {
  final FeedbackData feedbackData;
  final String recordedFilePath;

  const CustomFeedback(
      {super.key, required this.feedbackData, required this.recordedFilePath});

  @override
  State<CustomFeedback> createState() => _CustomFeedbackState();
}

class _CustomFeedbackState extends State<CustomFeedback> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playUserRecording() async {
    await _audioPlayer.play(DeviceFileSource(widget.recordedFilePath));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Dialog(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.62,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: constraints.maxHeight * 0.05),
                    RichText(
                      text: TextSpan(
                        children: customUserText(
                            "widget.feedbackData.userAudioText,",
                            widget.feedbackData.mistakenIndexes),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.025),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: widget.feedbackData.userScore / 100.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF26647)),
                                minHeight: constraints.maxHeight * 0.016,
                              ),
                            ),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.025),
                          Text(
                            '${widget.feedbackData.userScore.toString()}%',
                            style: TextStyle(
                                fontSize: constraints.maxHeight * 0.02,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF26647)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    // SizedBox(
                    //   height: constraints.maxHeight * 0.06,
                    //   child: RichText(
                    //     textAlign: TextAlign.center,
                    //     text: TextSpan(
                    //       children: recommendText(
                    //         widget.feedbackData.recommendCardId,
                    //         widget.feedbackData.recommendCardText,
                    //         widget.feedbackData.recommendCardCategory,
                    //         widget.feedbackData.recommendCardSubcategory,
                    //         context,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: constraints.maxHeight * 0.027),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center, // 내부 Stack의 정렬을 중앙으로 설정
                        children: [
                          Image.asset(
                            'assets/graph.png',
                          ), // 그래프 이미지
                          Positioned(
                            left: constraints.maxWidth * 0.0468,
                            bottom: constraints.minHeight * 0.1712,
                            child: Container(
                              child: const Text('원래는 그림이어따'),
                            ),
                          ),
                          Positioned(
                            left: constraints.maxWidth * 0.0468,
                            bottom: constraints.maxHeight * 0.034,
                            child: Container(
                              child: const Text('원래는 그림이어따!!!!'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //사용자 발음 듣기
              Positioned(
                right: 14,
                bottom: constraints.maxHeight * 0.26,
                child: IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    color: Color(0xFF644829),
                  ),
                  iconSize: constraints.maxHeight * 0.03,
                  onPressed: _playUserRecording,
                ),
              ),

              //표준 발음 듣기
              Positioned(
                right: 14,
                bottom: constraints.maxHeight * 0.12,
                child: IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    color: Color(0xFFF26647),
                  ),
                  iconSize: constraints.maxHeight * 0.03,
                  onPressed: () {
                    CustomTtsService.instance
                        .playCachedAudio(widget.feedbackData.cardId);
                  },
                ),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: constraints.maxHeight * 0.034,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
