import 'dart:io';
import 'dart:convert';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';

class AudioRecorderUtil {
  static final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  static bool _isRecorderInitialized = false;

  static Future<void> init() async {
    if (_isRecorderInitialized) return;

    // final status = await Permission.microphone.request();
    // if (status != PermissionStatus.granted) {
    //   //throw RecordingPermissionException('Microphone permission not granted');
    // }

    await _recorder.openAudioSession();
    _isRecorderInitialized = true;
  }

  static Future<void> dispose() async {
    if (!_isRecorderInitialized) return;
    await _recorder.closeAudioSession();
    _isRecorderInitialized = false;
  }

  static Future<String> startRecording(int cardId) async {
    await init();
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/userAudio_$cardId.wav';
    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
    );
    return path;
  }

  static Future<void> stopRecording() async {
    await _recorder.stopRecorder();
  }

  static bool get isRecording => _recorder.isRecording;

  static Future<String> encodedUserAudioToBase64(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }
}
