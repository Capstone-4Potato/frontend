import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/function.dart';
import 'package:flutter_application_1/ttsservice.dart';

class FeedbackUI extends StatefulWidget {
  final FeedbackData feedbackData;

  FeedbackUI({required this.feedbackData});

  @override
  State<FeedbackUI> createState() => _FeedbackUIState();
}

class _FeedbackUIState extends State<FeedbackUI> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.62,
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                SizedBox(height: 45),
                RichText(
                  text: TextSpan(
                    children: buildTextSpans(widget.feedbackData.userAudioText,
                        widget.feedbackData.mistakenIndexes),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: widget.feedbackData.userScore / 100.0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFF26647)),
                            minHeight: 14,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${widget.feedbackData.userScore.toString()}%',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF26647)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    children: recommendText(
                      widget.feedbackData.recommendCardId,
                      widget.feedbackData.recommendCardText,
                      widget.feedbackData.recommendCardCategory,
                      widget.feedbackData.recommendCardSubcategory,
                      context,
                    ),
                  ),
                ),
                SizedBox(height: 35),
                Stack(
                  alignment: Alignment.center, // 내부 Stack의 정렬을 중앙으로 설정
                  children: [
                    Image.asset(
                      'assets/image copy.png',
                      //height: 280,
                    ), // 그래프 이미지
                    Positioned(
                      left: 11.5,
                      bottom: 144.5,
                      child: Image.memory(
                        widget.feedbackData.userWaveformImage,
                        width: 240,
                        height: 90,
                      ),
                    ),
                    Positioned(
                      left: 11.8,
                      bottom: 27.1,
                      child: Image.memory(
                        widget.feedbackData.correctWaveformImage,
                        width: 240,
                        height: 90,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //사용자 발음 듣기
          Positioned(
            right: 14,
            bottom: 250,
            child: IconButton(
              icon: Icon(
                Icons.volume_up,
                color: Color(0xFF644829),
              ),
              iconSize: 25.0,
              // onPressed: _playRecording,
              //****수정!!!!!!!!!!!!! */
              onPressed: () {
                TtsService.instance.playCachedAudio(widget.feedbackData.cardId);
              },
            ),
          ),

          //표준 발음 듣기
          Positioned(
            right: 14,
            bottom: 128,
            child: IconButton(
              icon: Icon(
                Icons.volume_up,
                color: Color(0xFFF26647),
              ),
              iconSize: 25.0,
              // onPressed: _playRecording,
              //이거 듣고나서 어쨋든 녹음진행은 안댐 ;;;;
              onPressed: () {
                TtsService.instance.playCachedAudio(widget.feedbackData.cardId);
              },
            ),
          ),
          Positioned(
            right: 5,
            top: 5,
            child: IconButton(
              icon: Icon(Icons.close),
              iconSize: 25.0,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
