import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/token.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerUtil {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<String> fetchAndSaveBase64CorrectAudio(int cardId) async {
    var url = Uri.parse('http://potato.seatnullnull.com/cards/$cardId');
    String? token = await getAccessToken();

    try {
      var response = await http.get(
        url,
        headers: <String, String>{
          'access': '$token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // base64 데이터 디코딩
        final bytes = base64Decode(jsonData['correctAudio']);

        // 로컬 파일 경로 생성
        final file = await _getLocalFile('correctAudio_$cardId.wav');

        // 바이트 배열을 파일로 쓰기
        await file.writeAsBytes(bytes);

        //서버로부터 받은 correctaudiobase64 string 저장해놓기
        saveCorrectAudioBase64(jsonData['correctAudio']);

        // 파일 경로 반환
        return file.path;
      } else {
        throw Exception('Failed to load audio');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // 주어진 파일 경로의 오디오 파일 재생
  static Future<void> playLocalFile(String filePath) async {
    try {
      await _audioPlayer.play(filePath, isLocal: true);
    } catch (e) {
      print('Error: $e');
    }
  }

  // 로컬 파일 경로 생성
  static Future<File> _getLocalFile(String filename) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/$filename');
  }

  // 완전히 중지
  static Future<void> stop() async {
    await _audioPlayer.stop();
  }

  static bool isPlaying() {
    return _audioPlayer.state == PlayerState.PLAYING;
  }

  static String saveCorrectAudioBase64(String base64Audio) {
    return base64Audio;
  }
}
