import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'devices_event.dart';
part 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  DevicesBloc() : super(DevicesInitial());

  @override
  Stream<DevicesState> mapEventToState(
    DevicesEvent event,
  ) async* {
    if (event is DevicesToManual) {
      yield DevicesFromField();
    }
    if (event is DevicesToDropDown) {
      yield DevicesInitial();
    }
  }
}
