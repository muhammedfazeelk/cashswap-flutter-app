import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class MatchEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadMatches extends MatchEvent {}

abstract class MatchState extends Equatable {
  @override List<Object?> get props => [];
}
class MatchInitial extends MatchState {}
class MatchLoading extends MatchState {}
class MatchLoaded extends MatchState {
  final List<Map<String, dynamic>> matches;
  MatchLoaded(this.matches);
  @override List<Object?> get props => [matches];
}
class MatchError extends MatchState {
  final String message;
  MatchError(this.message);
}

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  MatchBloc() : super(MatchInitial()) {
    on<LoadMatches>(_onLoad);
  }

  Future<void> _onLoad(LoadMatches event, Emitter<MatchState> emit) async {
    emit(MatchLoading());
    try {
      // Load from API
      emit(MatchLoaded(const []));
    } catch (e) {
      emit(MatchError(e.toString()));
    }
  }
}
