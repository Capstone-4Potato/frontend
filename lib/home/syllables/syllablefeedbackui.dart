import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feedback_data.dart';
import 'package:flutter_application_1/ttsservice.dart';

class FeedbackUI extends StatefulWidget {
  final FeedbackData feedbackData;
  final String recordedFilePath;

  const FeedbackUI(
      {super.key, required this.feedbackData, required this.recordedFilePath});

  @override
  State<FeedbackUI> createState() => _FeedbackUIState();
}

class _FeedbackUIState extends State<FeedbackUI> {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Dialog(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: <Widget>[
              Container(
                width: constraints.maxWidth * 0.8,
                height: constraints.maxHeight * 0.45,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.025),
                      child: Row(
                        children: [
                          SizedBox(width: constraints.maxWidth * 0.025),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: constraints.maxHeight * 0.057,
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/graph.png',
                          ),
                          Positioned(
                            left: constraints.maxWidth * 0.0468,
                            bottom: constraints.minHeight * 0.1712,
                            child: Image.memory(
                              widget.feedbackData.userWaveformImage,
                              width: constraints.maxWidth * 0.6,
                              height: constraints.maxHeight * 0.14,
                            ),
                          ),
                          Positioned(
                            left: constraints.maxWidth * 0.0468,
                            bottom: constraints.maxHeight * 0.034,
                            child: Image.memory(
                              widget.feedbackData.correctWaveformImage,
                              width: constraints.maxWidth * 0.6,
                              height: constraints.maxHeight * 0.14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                    TtsService.instance
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
