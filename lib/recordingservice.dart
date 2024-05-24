import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class RecordingService {
  static final RecordingService _instance = RecordingService._internal();
  // 추가: instance에 대한 getter 메서드
  static RecordingService get instance => _instance;

  RecordingService._internal();

  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _baseUrl = 'http://potato.seatnullnull.com/cards/';

  String? base64UserAudio; // 여기에 base64 오디오 데이터를 저장합니다.

  static Future<void> fetchCorrectAudio(int cardId) async {
    final audioUrl =
        '$_baseUrl$cardId?cacheBuster=${DateTime.now().millisecondsSinceEpoch}';
    try {
      final response = await http.get(Uri.parse(audioUrl));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final String base64correctAudio = jsonData['correctAudio'] as String;
        _instance.base64UserAudio = base64correctAudio;
        // Save audio to a file
        await _instance.saveUserAudioToFile(cardId, base64correctAudio);
        print(_instance.base64UserAudio);
        return; // Return the base64 string of the correct audio
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        throw Exception('Failed to load audio: $errorMessage');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw e;
    }
  }

  Future<void> saveUserAudioToFile(int cardId, String base64Audio) async {
    final Uint8List bytes = base64Decode(base64Audio);
    final String dir = (await getTemporaryDirectory()).path;
    final String fileName = 'user_audio_$cardId.wav'; // 파일 이름을 cardId에 기반하여 생성
    final File file = File('$dir/$fileName');

    // Write bytes to a temporary file
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> playUserAudio(int cardId) async {
    final String dir = (await getTemporaryDirectory()).path;
    final String fileName = 'user_audio_$cardId.wav'; // 파일 이름을 cardId에 기반하여 생성
    final File file = File('$dir/$fileName');

    if (await file.exists()) {
      // 캐시된 오디오 파일이 이미 존재하면 해당 파일을 사용하여 재생합니다.
      await _audioPlayer.setUrl(file.path, isLocal: true);
      await _audioPlayer.play(file.path, isLocal: true);
    } else {
      throw Exception('Cached audio file does not exist.');
    }
  }
}
