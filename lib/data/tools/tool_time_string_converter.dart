class ToolTimeStringConverter {
  String formatSecondsToTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    if (hours > 0 && minutes == 0) {
      minutesStr = '00';
    }
    String secondsStr = (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';
    return '$hours:$minutesStr:$secondsStr';
  }

  String formatSecondsToTimeMinute(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr = (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';
    return '$minutesStr:$secondsStr';
  }

  String formatSecondsToTimeWithoutZero(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String hoursStr = (hours > 0) ? '$hours:' : '';
    String minutesStr = (minutes > 0 || hours > 0)
        ? '${(minutes < 10 && hours > 0) ? '0$minutes' : '$minutes'}:'
        : '';
    String secondsStr = (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';

    return '$hoursStr$minutesStr$secondsStr';
  }
}
