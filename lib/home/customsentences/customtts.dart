import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class CustomTtsService {
  static final CustomTtsService _instance = CustomTtsService._internal();
  // 추가: instance에 대한 getter 메서드
  static CustomTtsService get instance => _instance;

  CustomTtsService._internal();

  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final String _baseUrl = '$main_url/cards/custom/';

  String? base64CorrectAudio; // 여기에 base64 오디오 데이터를 저장합니다.

  // 맞춤 문장 correctAudio API
  static Future<void> fetchCorrectAudio(int cardId) async {
    String? token = await getAccessToken();
    final audioUrl = '$_baseUrl$cardId';
    try {
      final response = await http.get(
        Uri.parse(audioUrl),
        headers: <String, String>{
          'access': '$token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('customtts fetch complete');

        final jsonData = jsonDecode(response.body);
        final String? base64correctAudio = jsonData['correctAudio'];
        // print(base64correctAudio);
        _instance.base64CorrectAudio = base64correctAudio;
        // Save audio to a file
        await _instance.saveAudioToFile(cardId, base64correctAudio);

        return; // Return the base64 string of the correct audio
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh and retry the request
        print('Access token expired. Refreshing token...');

        // Refresh the token
        bool isRefreshed = await refreshAccessToken();

        if (isRefreshed) {
          // Retry request with new token
          print('Token refreshed successfully. Retrying request...');
          String? newToken = await getAccessToken();
          final retryResponse = await http.get(
            Uri.parse(audioUrl),
            headers: <String, String>{
              'access': '$newToken',
              'Content-Type': 'application/json',
            },
          );

          if (retryResponse.statusCode == 200) {
            final jsonData = jsonDecode(retryResponse.body);
            final String base64correctAudio = jsonData['correctAudio'];
            print(base64correctAudio);
            _instance.base64CorrectAudio = base64correctAudio;
            await _instance.saveAudioToFile(cardId, base64correctAudio);
            return; // Return the base64 string of the correct audio
          } else {
            final errorMessage = jsonDecode(retryResponse.body)['message'];
            throw Exception('Failed to load audio after retry: $errorMessage');
          }
        } else {
          print('Failed to refresh token. Please log in again.');
          throw Exception('Failed to refresh token.');
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        throw Exception('Failed to load audio: $errorMessage');
      }
    } catch (e) {
      print('Error occurred: $e');
      rethrow;
    }
  }

  Future<void> saveAudioToFile(int cardId, String? base64String) async {
    final bytes = base64Decode(base64String!);
    final String dir = (await getTemporaryDirectory()).path;
    final String fileName =
        'custom_correct_audio_$cardId.wav'; // 파일 이름을 cardId에 기반하여 생성
    final File file = File('$dir/$fileName');

    // Write bytes to a temporary file
    await file.writeAsBytes(bytes);
  }

  Future<void> playCachedAudio(int cardId) async {
    final String dir = (await getTemporaryDirectory()).path;
    final String fileName =
        'custom_correct_audio_$cardId.wav'; // 파일 이름을 cardId에 기반하여 생성
    final File file = File('$dir/$fileName');
    await _audioPlayer.play(DeviceFileSource(file.path));
  }

  Future<void> stopAudioPlayer() async {
    await _audioPlayer.stop();
    await _audioPlayer.release(); // 명시적으로 오디오 세션 해제
  }
}
