import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/token.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  // 추가: instance에 대한 getter 메서드
  static TtsService get instance => _instance;

  TtsService._internal();

  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _baseUrl = 'http://potato.seatnullnull.com/cards/';

  String? base64CorrectAudio; // 여기에 base64 오디오 데이터를 저장합니다.

  static Future<void> fetchCorrectAudio(int cardId) async {
    String? token = await getAccessToken();
    final audioUrl = '$_baseUrl$cardId';
    try {
      final response = await http.get(
        Uri.parse(audioUrl),
        headers: <String, String>{
          'access': '$token',
          // 'access':
          //     'eyJhbGciOiJIUzI1NiJ9.eyJjYXRlZ29yeSI6ImFjY2VzcyIsInNvY2lhbElkIjoiMzQ1MzcwNDI4OSIsInJvbGUiOiJST0xFX0FETUlOIiwiaWF0IjoxNzE1NTA1MDA2LCJleHAiOjE3MTgwOTcwMDZ9.a744Z7lTIIFQjul6-fLCp-Y4MN9LxqdLX8U9_GyGwIA',

          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final String base64correctAudio = jsonData['correctAudio'];
        _instance.base64CorrectAudio = base64correctAudio;
        // Save audio to a file
        await _instance.saveAudioToFile(cardId, base64correctAudio);

        return; // Return the base64 string of the correct audio
      } else {
        final jsonData = jsonDecode(response.body);
        print(jsonData);
        final errorMessage = jsonDecode(response.body)['message'];
        throw Exception('Failed to load audio: $errorMessage');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw e;
    }
  }

  Future<void> saveAudioToFile(int cardId, String base64String) async {
    final bytes = base64Decode(base64String);
    final String dir = (await getTemporaryDirectory()).path;
    final String fileName =
        'correct_audio_$cardId.wav'; // 파일 이름을 cardId에 기반하여 생성
    final File file = File('$dir/$fileName');

    // Write bytes to a temporary file
    await file.writeAsBytes(bytes);
  }

  Future<void> playCachedAudio(int cardId) async {
    final String dir = (await getTemporaryDirectory()).path;
    final String fileName =
        'correct_audio_$cardId.wav'; // 파일 이름을 cardId에 기반하여 생성
    final File file = File('$dir/$fileName');
    await _audioPlayer.play(DeviceFileSource(file.path));
  }

  Future<void> stopAudioPlayer() async {
    await _audioPlayer.stop();
    await _audioPlayer.release(); // 명시적으로 오디오 세션 해제
  }
}
