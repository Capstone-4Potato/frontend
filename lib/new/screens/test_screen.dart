import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class TestCardScreen extends StatefulWidget {
  const TestCardScreen({super.key});

  @override
  _TestCardScreenState createState() => _TestCardScreenState();
}

class _TestCardScreenState extends State<TestCardScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _player.openPlayer();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> _startOrStopRecording() async {
    if (_isRecording) {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _filePath = path;
      });
    } else {
      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/record.wav';
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
        _filePath = path;
      });
    }
  }

  Future<void> _playRecording() async {
    if (_filePath != null) {
      await _player.startPlayer(fromURI: _filePath!, codec: Codec.pcm16WAV);
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음성 녹음 및 재생')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _startOrStopRecording,
              child: Text(_isRecording ? '녹음 중지' : '녹음 시작'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _filePath == null ? null : _playRecording,
              child: const Text('녹음된 음성 듣기'),
            ),
          ],
        ),
      ),
    );
  }
}
