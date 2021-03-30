import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'server_event.dart';
part 'server_state.dart';

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  ServerBloc() : super(ServerInitial());

  @override
  Stream<ServerState> mapEventToState(
    ServerEvent event,
  ) async* {
   if (event is ServerToManual) {
     yield ServerFromField();
   }
   if (event is ServerToDropDown) {
     yield ServerInitial();
   }
  }
}
