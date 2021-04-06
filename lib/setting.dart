import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_ilolly/blocs/devices/devices_bloc.dart';
import 'package:push_ilolly/blocs/upload/upload_bloc.dart';

import 'blocs/resource/resource_bloc.dart';
import 'blocs/server/server_bloc.dart';

class Setting extends StatefulWidget {
  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    final uploadBloc = BlocProvider.of<UploadBloc>(context);
    uploadBloc.add(UploadBeforeToServer());
    return WillPopScope(
      onWillPop: () async {
        final uploadBloc = BlocProvider.of<UploadBloc>(context);
        uploadBloc.add(UploadToInit());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '機台設置',
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: BlocBuilder<UploadBloc, UploadState>(
                //buildWhen: (previousState, state) => state.runtimeType != previousState.runtimeType,
                builder: (context, state) {
                  print("state:$state");
                  if (state is UploadSuccess) {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            '人臉辨識機文字轉聲音設定成功，可以返回首頁進行測試',
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 30,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              UploadBloc uploadBloc =
                                  BlocProvider.of<UploadBloc>(context);
                              ServerBloc serverBloc =
                                  BlocProvider.of<ServerBloc>(context);
                              ResourceBloc resourceBloc =
                                  BlocProvider.of<ResourceBloc>(context);
                              DevicesBloc devicesBloc =
                                  BlocProvider.of<DevicesBloc>(context);
                              uploadBloc.add(UploadToInit());
                              serverBloc.add(ServerToDropDown());
                              resourceBloc.add(ResourceToInit());
                              devicesBloc.add(DevicesToDropDown());
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: Text(
                              "返回首頁",
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is UploadFailed) {
                    return Container(
                      child: Center(
                        child: Text(
                          "人臉辨識機聲音設置失敗，請確認伺服器網址輸入及機台序號是否正確",
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
