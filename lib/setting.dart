import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_ilolly/blocs/upload/upload_bloc.dart';

class Setting extends StatefulWidget{
  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '機台設置',
        ),
      ),
      body: BlocProvider(
        create: (context) => UploadBloc(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: BlocBuilder<UploadBloc, UploadState>(
                builder: (context, state) {
                  final uploadBloc = BlocProvider.of<UploadBloc>(context);
                  print(state);
                  if (state is UploadSuccess) {
                    return Center(
                      child: Column(
                        children: [
                          Text('人臉辨識機文字轉聲音設定成功，可以返回首頁進行測試',),
                          Padding(
                            padding: EdgeInsets.only(top: 30,),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                            child: Text("返回首頁",),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is UploadInitial) {
                    uploadBloc.add(UploadBeforeToServer());
                  }
                  if (state is UploadLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Container(
                    child: Center(
                      child: Text(
                        "人臉辨識機聲音設置失敗，請確認伺服器網址輸入及機台序號是否正確",
                      ),
                    ),
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