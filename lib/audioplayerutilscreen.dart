import 'package:flutter/material.dart';
import 'audioplayerutil.dart';
import 'audiorecorderutil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Audio Player and Recorder Example'),
        ),
        body: Center(
          child: AudioWidget(),
        ),
      ),
    );
  }
}

class AudioWidget extends StatefulWidget {
  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  String? _correctAudioPath;
  String? _userAudioPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  final int cardId = 1; // 적절한 cardId 입력

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isRecording || _isPlaying ? null : _fetchCorrectAudio,
          child: Text('Fetch Correct Audio'),
        ),
        if (_correctAudioPath != null) ...[
          ElevatedButton(
            onPressed: _isRecording || _isPlaying
                ? null
                : () => _playAudio(_correctAudioPath!),
            child: Text('Play Correct Audio'),
          ),
        ],
        ElevatedButton(
          onPressed: _toggleRecording,
          child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
        if (_userAudioPath != null) ...[
          ElevatedButton(
            onPressed: _isRecording || _isPlaying
                ? null
                : () => _playAudio(_userAudioPath!),
            child: Text('Play User Recording'),
          ),
        ],
      ],
    );
  }

  Future<void> _fetchCorrectAudio() async {
    try {
      _correctAudioPath =
          await AudioPlayerUtil.fetchAndSaveBase64CorrectAudio(cardId);
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _playAudio(String filePath) async {
    setState(() {
      _isPlaying = true;
    });
    await AudioPlayerUtil.playLocalFile(filePath);
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await AudioRecorderUtil.stopRecording();
      setState(() {
        _isRecording = false;
      });
    } else {
      if (AudioPlayerUtil.isPlaying()) {
        await AudioPlayerUtil.stop();
      }
      _userAudioPath = await AudioRecorderUtil.startRecording(cardId);
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  void dispose() {
    AudioRecorderUtil.dispose();
    super.dispose();
  }
}
