import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../data/services/service_shared_preferences.dart';

enum SettingsKey {
  notificationsEnabled,
  language,
  themeName,
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ServiceSharedPreferences _prefs = Get.find<ServiceSharedPreferences>();

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
  }

  Future<void> _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    // Читаем настройки из SharedPreferences
    final notificationsStr = _prefs.getString(key: SettingsKey.notificationsEnabled.name) ?? 'true';
    final isNotificationsEnabled = notificationsStr == 'true';

    final language = _prefs.getString(key: SettingsKey.language.name) ?? 'Русский';

    // Эмитим заглушки для остальных данных вместе с реальными настройками
    emit(state.copyWith(
      isLoaded: true,
      isNotificationsEnabled: isNotificationsEnabled,
      language: language,
      themeName: 'Тёмная (System)',
      appVersion: '1.2.4 (Build 42)',
      lastSyncDate: 'Сегодня в 12:40',
    ));
  }

  Future<void> _onToggleNotifications(ToggleNotificationsEvent event, Emitter<SettingsState> emit) async {
    final newValue = event.isEnabled;
    _prefs.putString(key: SettingsKey.notificationsEnabled.name, stringData: newValue.toString());
    emit(state.copyWith(isNotificationsEnabled: newValue));
  }
}

class SettingsState {
  final bool isLoaded;
  final bool isNotificationsEnabled;
  final String themeName;
  final String language;
  final String appVersion;
  final String lastSyncDate;

  const SettingsState({
    this.isLoaded = false,
    this.isNotificationsEnabled = true,
    this.themeName = 'Тёмная (System)',
    this.language = 'Русский',
    this.appVersion = '...',
    this.lastSyncDate = 'Нет данных',
  });

  SettingsState copyWith({
    bool? isLoaded,
    bool? isNotificationsEnabled,
    String? themeName,
    String? language,
    String? appVersion,
    String? lastSyncDate,
  }) {
    return SettingsState(
      isLoaded: isLoaded ?? this.isLoaded,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      themeName: themeName ?? this.themeName,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
    );
  }
}

abstract class SettingsEvent {}

class LoadSettingsEvent extends SettingsEvent {}

class ToggleNotificationsEvent extends SettingsEvent {
  final bool isEnabled;
  ToggleNotificationsEvent(this.isEnabled);
}
