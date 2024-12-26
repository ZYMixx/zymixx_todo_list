import 'package:audioplayers/audioplayers.dart';

class ServiceAudioPlayer {

  List<int> ignoreTodoItemIdList = [];

  AudioPlayer? _playAssetsAudio(String assetsPath, {double? volume}) {
    try {
      AudioPlayer audioPlayer = AudioPlayer()..setSource(AssetSource(assetsPath));
      audioPlayer.setVolume(volume ?? 0.15);
      audioPlayer.onPlayerComplete.listen((event) => audioPlayer.dispose());
      audioPlayer.resume();
      return audioPlayer;
    } catch (e) {}
  }

  playFortuneWinAlert() {
    return _playAssetsAudio('songs/spinner_win_sound.mp3');
  }

  playFortuneWinMusic({required double volume}) {
    return _playAssetsAudio('songs/spinner_win_music_sound.mp3', volume: volume);
  }

  AudioPlayer? playFortuneSpinnerMusic() {
    return _playAssetsAudio('songs/spinner_gamble_sound.mp3');
  }

  playTimerAlert() {
    _playAssetsAudio('songs/timer_music_alert.mp3', volume: 0.10);
  }
}

// flutter pub add audioplayers
//   assets:
//     - assets/
//     - assets/songs/