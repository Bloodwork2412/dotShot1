import 'package:flutter_bloc/flutter_bloc.dart';

// needed for BlocProvider, mostly useless from template I believe
class GameStateCubit extends Bloc<GameEvent, GameCurrentState> {
  GameStateCubit() : super(GameCurrentState(0)) {
    on<AddScoreGameEvent>((event, emit) async {
      emit(GameCurrentState(state.score + event.score));
    });
  }
}

abstract class GameEvent {}

class AddScoreGameEvent extends GameEvent {
  int score;

  AddScoreGameEvent(this.score);
}

class GameCurrentState {
  int score = 0;

  GameCurrentState(this.score);
}
