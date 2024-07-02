import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/customsentence/customtts.dart';
import 'package:flutter_application_1/customsentence/feedbackusertext.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/function.dart';

class CustomFeedback extends StatefulWidget {
  final FeedbackData feedbackData;
  final String recordedFilePath;

  CustomFeedback({required this.feedbackData, required this.recordedFilePath});

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
                    children: customUserText(widget.feedbackData.userAudioText,
                        widget.feedbackData.mistakenIndexes),
                  ),
                ),
                SizedBox(height: 15),
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
                      left: 10,
                      bottom: 134.5,
                      child: Image.memory(
                        widget.feedbackData.userWaveformImage,
                        width: 240,
                        height: 90,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 25.5,
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
            bottom: 240,
            child: IconButton(
              icon: Icon(
                Icons.volume_up,
                color: Color(0xFF644829),
              ),
              iconSize: 25.0,
              onPressed: _playUserRecording,
            ),
          ),

          //표준 발음 듣기
          Positioned(
            right: 14,
            bottom: 125,
            child: IconButton(
              icon: Icon(
                Icons.volume_up,
                color: Color(0xFFF26647),
              ),
              iconSize: 25.0,
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
