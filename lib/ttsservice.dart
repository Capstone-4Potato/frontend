import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_application_1/userauthmanager.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  static TtsService get instance => _instance;

  TtsService._internal();

  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _baseUrl = 'http://potato.seatnullnull.com/cards/';

  String? base64CorrectAudio;

  // correctAudio를 서버에서 가져오는 메서드
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
        // 응답이 성공적인 경우
        final jsonData = jsonDecode(response.body); // 응답 데이터를 디코딩
        final String base64correctAudio =
            jsonData['correctAudio']; // 오디오 데이터 추출
        _instance.base64CorrectAudio = base64correctAudio; // 인스턴스 변수에 저장
        // 오디오 파일로 저장
        await _instance.saveAudioToFile(cardId, base64correctAudio);
        return;
      } else if (response.statusCode == 401) {
        // 토큰이 만료된 경우
        print('Access token expired. Refreshing token...');

        // 토큰 갱신 시도
        bool isRefreshed = await refreshAccessToken();

        if (isRefreshed) {
          // 갱신에 성공하면 요청을 다시 시도
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
            _instance.base64CorrectAudio = base64correctAudio;
            await _instance.saveAudioToFile(cardId, base64correctAudio);
            return;
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

  // 오디오 데이터를 파일로 저장하는 메서드
  Future<void> saveAudioToFile(int cardId, String base64String) async {
    final bytes = base64Decode(base64String);
    final String dir = (await getTemporaryDirectory()).path;
    final String fileName = 'correct_audio_$cardId.wav';
    final File file = File('$dir/$fileName');

    await file.writeAsBytes(bytes);
  }

  // 저장된 오디오 파일을 재생하는 메서드
  Future<void> playCachedAudio(int cardId) async {
    final String dir = (await getTemporaryDirectory()).path;
    final String fileName = 'correct_audio_$cardId.wav';
    final File file = File('$dir/$fileName');

    // 오디오 세션 설정 - 블루투스 우선 출력
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech()); // 스피치 모드

    // 오디오 플레이어에 블루투스 출력 설정 (기본 세션 우선 설정)
    _audioPlayer.setAudioContext(const AudioContext(
      iOS: AudioContextIOS(
        options: [
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowBluetoothA2DP,
        ],
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.voiceCommunication,
      ),
    ));

    await _audioPlayer.play(DeviceFileSource(file.path));
  }
}
