import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'token_event.dart';
part 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  TokenBloc() : super(TokenInitial());

  @override
  Stream<TokenState> mapEventToState(
    TokenEvent event,
  ) async* {
    if (event is NeedToSetToken) {
      yield TokenInitial();
    }
    if (event is CompletedToken) {
      yield TokenFinished();
    }
    if (event is ToSetToken) {
      yield TokenSetting();
    }
  }
}
