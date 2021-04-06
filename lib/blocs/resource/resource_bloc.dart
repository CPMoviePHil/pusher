import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:push_ilolly/values.dart';
import 'package:push_ilolly/models/SerialNumber.dart';

part 'resource_event.dart';
part 'resource_state.dart';

class ResourceBloc extends Bloc<ResourceEvent, ResourceState> {
  ResourceBloc() : super(ResourceInitial());

  @override
  Stream<ResourceState> mapEventToState(
    ResourceEvent event,
  ) async* {
    if (event is ResourceToInit) {
      yield ResourceInitial();
    }
    if (event is ResourceFetch) {
      try {
        Uri uri = Uri.parse(Values.server + '/api/face/indexMachineSerialNumber');
        final data = await http.post(
          uri,
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({}),
        );
        if (data.statusCode == 200) {
          if (json.decode(data.body)['result']) {
            List dk = json.decode(data.body)['data'] as List;
            yield ResourceSuccess(devices: dk.map((e) => SerialNumber.fromJson(e)).toList(),);
          } else {
            yield ResourceFailed();
          }
        } else {
          yield ResourceFailed();
        }
      } catch (e) {
        yield ResourceFailed();
      }
    }
    if (event is ResourceBeforeFetch) {
      yield ResourceLoading();
      add(ResourceFetch());
    }
  }
}
