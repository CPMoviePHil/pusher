import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_ilolly/prefs/utils.dart';
import 'package:push_ilolly/values.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(UploadInitial());

  @override
  Stream<UploadState> mapEventToState(
    UploadEvent event,
  ) async* {
    if (event is UploadToInit) {
      yield UploadInitial();
    }
    if (event is UploadBeforeToServer) {
      add(UploadToServer());
      yield UploadLoading();
    }
    if (event is UploadToServer) {
      try {
        Uri uri = Uri.parse(Values.server + '/api/face/updataMachineDeviceToken');
        print({
          "serial_number": Values.serial,
          "device_token": Values.deviceToken,
        });
        final data = await http.post(
          uri,
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "serial_number": Values.serial,
            "device_token": Values.deviceToken,
          },),
        );
        print(data.statusCode);
        if (data.statusCode == 200) {
          if (json.decode(data.body)['result']) {
            Prefs.preferences = await SharedPreferences.getInstance();
            Prefs.preferences.setString("server", Values.server,);
            Prefs.preferences.setString("serial", Values.serial,);
            Prefs.preferences.setString("deviceToken", Values.deviceToken,);
            Prefs.preferences.setBool("ttsSetting", true,);
            yield UploadSuccess();
          } else {
            yield UploadFailed();
          }
        } else {
          yield UploadFailed();
        }
      } catch (e) {
        yield UploadFailed();
      }
    }
  }
}
