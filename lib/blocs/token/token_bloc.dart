import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:push_ilolly/blocs/application/application_bloc.dart';
import 'package:push_ilolly/blocs/upload/upload_bloc.dart';
import 'package:push_ilolly/values.dart';

part 'token_event.dart';
part 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final UploadBloc uploadBloc;
  final ApplicationBloc applicationBloc;
  StreamSubscription subscription;
  StreamSubscription subscription2;

  TokenBloc({
    @required this.applicationBloc,
    @required this.uploadBloc,
  }) :super(TokenInitial()) {
    subscription = uploadBloc.stream.listen((state) {
      if (state is UploadSuccess) {
        add(CompletedToken());
      }
    });
    subscription2 = applicationBloc.stream.listen((state) {
      if (state is ApplicationSetupCompleted) {
        print(Values.ttsSetting);
        if (Values.ttsSetting == null) {
          add(NeedToSetToken());
        } else {
          if (Values.ttsSetting) {
            add(CompletedToken(deviceToken: Values.deviceToken,));
          }
        }
      }
    });
  }

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

  @override
  Future<void> close() {
    subscription.cancel();
    subscription2.cancel();
    return super.close();
  }
}
