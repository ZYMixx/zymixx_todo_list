import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
  }

  Future<void> _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    // TODO: загрузка настроек
    emit(state.copyWith(isLoaded: true));
  }
}

class SettingsState {
  final bool isLoaded;

  SettingsState({this.isLoaded = false});

  SettingsState copyWith({bool? isLoaded}) {
    return SettingsState(
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

abstract class SettingsEvent {}

class LoadSettingsEvent extends SettingsEvent {}
