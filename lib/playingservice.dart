import 'package:flutter_sound/flutter_sound.dart';

class PlayingService {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  Future<void> initPlayer() async {
    await _player.openAudioSession();
  }

  Future<void> playAudio(String path) async {
    await _player.startPlayer(fromURI: path);
  }

  Future<void> stopPlaying() async {
    await _player.stopPlayer();
  }

  Future<void> dispose() async {
    await _player.closeAudioSession();
  }
}
