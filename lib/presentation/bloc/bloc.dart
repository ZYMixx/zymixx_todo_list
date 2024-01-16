import 'package:flutter_bloc/flutter_bloc.dart';

class MyBloc extends Bloc<MyBlocEvent, MyBlocState> {
  MyBloc() : super(MyBlocState()) {
    on<MyBlocEvent>((event, emit) {
      print('do some thing');
    });
  }
}

class MyBlocState {}

class MyBlocEvent {}
