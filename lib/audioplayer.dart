import 'package:audioplayers/audioplayers.dart';

class AudioPlayerHelper {
  late AudioPlayer _audioPlayer;

  AudioPlayerHelper() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> playAudio(String filePath) async {
    int result = await _audioPlayer.play(filePath, isLocal: true);
    if (result == 1) {
      // 재생 성공
    } else {
      // 재생 실패
    }
  }

  void stopAudio() {
    _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
//녹음된 파일의 경로: /Users/pro/Library/Developer/CoreSimulator/Devices/12DEB9B1-C5A1-42E4-993C-E390B91E4C69/data/Containers/Data/Application/573E9871-336C-40E4-A0E4-7548676995F8/Library/Caches/user_audio.wav