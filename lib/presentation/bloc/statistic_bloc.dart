import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticBloc extends Bloc<StatisticEvent, StatisticState> {
  StatisticBloc() : super(StatisticState()) {
    on<StatisticEvent>((event, emit) {
      print('do some thing');
    });
  }
}

class StatisticState {}

class StatisticEvent {}
