import 'package:audioplayers/audioplayers.dart';

// flutter pub add audioplayers
//   assets:
//     - assets/
//     - assets/songs/

class ServiceAudioPlayer {
  static AudioPlayer? _playAssetsAudio(String assetsPath, {double? volume}) {
    try {
      AudioPlayer audioPlayer = AudioPlayer()..setSource(AssetSource(assetsPath));
      audioPlayer.setVolume(volume ?? 0.75);
      audioPlayer.onPlayerComplete.listen((event) => audioPlayer.dispose());
      audioPlayer.resume();
      return audioPlayer;
    } catch (e) {}
  }

  static playFortuneWinAlert() {
    return _playAssetsAudio('songs/spinner_win_sound.mp3');
  }

  static playFortuneWinMusic({required double volume}) {
    return _playAssetsAudio('songs/spinner_win_music_sound.mp3', volume: volume);
  }

  static AudioPlayer? playFortuneSpinnerMusic() {
    return _playAssetsAudio('songs/spinner_gamble_sound.mp3');
  }

  static playTimerAlert() {
    _playAssetsAudio('songs/timer_music_alert.mp3', volume: 0.4);
  }
}
