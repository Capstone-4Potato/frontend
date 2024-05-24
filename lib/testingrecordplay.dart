//import 'dart:convert';
//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_1/permissionservice.dart';
import 'package:flutter_application_1/ttsservice.dart';
import 'package:flutter_sound/flutter_sound.dart';
//import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PronunciationScreen(),
    );
  }
}

class PronunciationScreen extends StatefulWidget {
  @override
  _PronunciationScreenState createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final PermissionService _permissionService = PermissionService();
  bool _isRecording = false;
  late String _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _permissionService.requestPermissions();
    await _audioRecorder.openAudioSession();
  }

  // Future<void> _playBase64Wav(String base64String) async {
  //   final bytes = base64Decode(base64String);
  //   final dir = await getTemporaryDirectory();
  //   final file = File('${dir.path}/temp.wav');
  //   await file.writeAsBytes(bytes);
  //   await _audioPlayer.play(DeviceFileSource(file.path));
  // }

  Future<void> _recordAudio() async {
    if (_isRecording) {
      final path = await _audioRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path!;
      });
    } else {
      await _audioRecorder.startRecorder(
        toFile: 'audio_record.wav',
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
      });
    }
  }

  // Future<String> _fetchBase64WavFromServer() async {
  //   return 'base64-encoded-string-here';
  // }

  void _onListenPressed() async {
    final int cardId = 324; // Example card ID, replace with actual ID
    await TtsService.fetchCorrectAudio(cardId);
    await TtsService.instance.playCachedAudio(cardId);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.closeAudioSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pronunciation Practice'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Text(
                    '세수',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '[세ː수]',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    '[sesu]',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _onListenPressed,
                    icon: Icon(Icons.play_arrow),
                    label: Text('Listen'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _recordAudio,
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    label: Text(_isRecording ? 'Stop Recording' : 'Record'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _audioPlayer
                          .play(DeviceFileSource(_recordedFilePath));
                    },
                    icon: Icon(Icons.play_arrow),
                    label: Text('Play Recording'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
