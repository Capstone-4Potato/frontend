//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Grid Demo',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: AudioRecorderPlayer(),
    );
  }
}

class AudioRecorderPlayer extends StatefulWidget {
  @override
  _AudioRecorderPlayerState createState() => _AudioRecorderPlayerState();
}

class _AudioRecorderPlayerState extends State<AudioRecorderPlayer> {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _filePathUserAudio;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();

    await _recorder!.openAudioSession();
    //final status = await _recorder!.requestRecordPermission();
    //
  }

  Future<void> _startRecording() async {
    final directory = await getTemporaryDirectory();
    _filePathUserAudio = '${directory.path}/user_audio.wav';

    await _recorder!.startRecorder(toFile: _filePathUserAudio);
    setState(() {
      _isRecording = true;
    });
    print('Recording to: $_filePathUserAudio');
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    print('Recording stopped');
  }

  Future<void> _playAudio() async {
    if (_filePathUserAudio != null) {
      await _audioPlayer.setFilePath(_filePathUserAudio!);
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _recorder!.closeAudioSession();
    _recorder = null;
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Recorder and Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: !_isRecording ? null : _stopRecording,
              child: Text('Stop Recording'),
            ),
            ElevatedButton(
              onPressed: _playAudio,
              child: Text('Play Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
