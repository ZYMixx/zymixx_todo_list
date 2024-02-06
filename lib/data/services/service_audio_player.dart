import 'package:audioplayers/audioplayers.dart';

// flutter pub add audioplayers
//   assets:
//     - assets/
//     - assets/songs/

class ServiceAudioPlayer {
  static _playAssetsAudio(String assetsPath) {
    try {
      AudioPlayer audioPlayer = AudioPlayer()..setSource(AssetSource(assetsPath));
      audioPlayer.setVolume(0.75);
      audioPlayer.onPlayerComplete.listen((event) => audioPlayer.dispose());
      audioPlayer.resume();
    } catch (e) {}
  }

  static playTimerAlert() {
    _playAssetsAudio('songs/timer_music_alert.mp3');
  }
}
