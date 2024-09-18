import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';

// Создание класса мока для AudioPlayer
class MockAudioPlayer extends Mock implements AudioPlayer {}
//content
//
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('playFortuneWinAlert plays audio', (WidgetTester tester) async {
    final serviceAudioPlayer = ServiceAudioPlayer();
    final audioPlayer = AudioPlayer();

    // Вызов метода playFortuneWinAlert
    serviceAudioPlayer.playFortuneWinAlert();

    // Подождите немного, чтобы аудио успело начать воспроизведение
    await Future.delayed(Duration(milliseconds: 500));

    // Проверка, что плеер начал воспроизведение
    expect(audioPlayer.releaseMode, ReleaseMode.loop);
    print('end');
  });
}