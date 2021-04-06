import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:push_ilolly/blocs/token/token_bloc.dart';
import 'package:push_ilolly/prefs/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:push_ilolly/values.dart';

part 'application_event.dart';
part 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {

  ApplicationBloc() : super(ApplicationInitial());

  @override
  Stream<ApplicationState> mapEventToState(
    ApplicationEvent event,
  ) async* {
    if (event is GetApplicationEvent) {
      Prefs.preferences = await SharedPreferences.getInstance();
      Values.ttsSetting = Prefs.preferences.getBool('ttsSetting');
      Values.server = Prefs.preferences.getString('server');
      Values.serial = Prefs.preferences.getString('serial');
      //Values.deviceToken = Prefs.preferences.getString('deviceToken');
      yield ApplicationSetupCompleted();
     }
    if (event is BeforeGetApplicationEvent) {
      yield ApplicationSetting();
      add(GetApplicationEvent());
    }
  }
}
