import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ServiceAudioPlayer {
  List<int> ignoreTodoItemIdList = [];
  final List<AudioPlayer> _activePlayers = [];

  AudioPlayer? _playAssetsAudio(String assetsPath, {double? volume}) {
    try {
      AudioPlayer audioPlayer = AudioPlayer()
        ..setSource(AssetSource(assetsPath));
      audioPlayer.setVolume(volume ?? 0.15);
      _activePlayers.add(audioPlayer);
      audioPlayer.onPlayerComplete.listen((event) {
        _activePlayers.remove(audioPlayer);
        audioPlayer.dispose();
      });
      audioPlayer.resume();
      return audioPlayer;
    } catch (e) {
      return null;
    }
  }

  void stopAll() {
    for (var player in _activePlayers) {
      player.stop();
      player.dispose();
    }
    _activePlayers.clear();
  }

  playFortuneWinAlert() {
    return _playAssetsAudio('songs/spinner_win_sound.mp3');
  }

  playFortuneWinMusic({required double volume}) {
    return _playAssetsAudio('songs/spinner_win_music_sound.mp3',
        volume: volume);
  }

  AudioPlayer? playFortuneSpinnerMusic() {
    return _playAssetsAudio('songs/spinner_gamble_sound.mp3');
  }

  playTimerAlert() {
    if (GetPlatform.isMobile) {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
      return;
    }
    _playAssetsAudio('songs/timer_music_alert.mp3', volume: 0.10);
  }
}

// flutter pub add audioplayers
//   assets:
//     - assets/
//     - assets/songs/
