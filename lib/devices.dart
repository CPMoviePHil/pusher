import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_ilolly/blocs/devices/devices_bloc.dart';
import 'package:push_ilolly/blocs/resource/resource_bloc.dart';
import 'package:push_ilolly/blocs/upload/upload_bloc.dart';
import 'package:push_ilolly/models/SerialNumber.dart';
import 'package:push_ilolly/setting.dart';
import 'package:push_ilolly/values.dart';

class Devices extends StatefulWidget{
  @override
  _DevicesPage createState()=> _DevicesPage();
}

class _DevicesPage extends State<Devices> {
  TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '選擇機台序號',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: BlocBuilder<ResourceBloc, ResourceState>(
              builder: (context, state) {
                print(state);
                final resourceBloc = BlocProvider.of<ResourceBloc>(context);
                if (state is ResourceFailed) {
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          "無法取得裝置序號,，可能是伺服器網址輸入錯誤，請返回上個步驟重新輸入或重新重入",
                        ),
                        ElevatedButton(
                          onPressed: () => resourceBloc.add(
                            ResourceFetch(),
                          ),
                          child: Text("重新載入",),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ResourceInitial) {
                  resourceBloc.add(ResourceBeforeFetch());
                }
                if (state is ResourceSuccess) {
                  final List<SerialNumber> devices = state.devices;
                  return BlocBuilder<DevicesBloc, DevicesState>(
                    builder: (context, state) {
                      final devicesBloc = BlocProvider.of<DevicesBloc>(context);
                      if (state is DevicesFromField) {
                        textEditingController = TextEditingController();
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: TextField(
                                    controller: textEditingController,
                                    decoration: InputDecoration(
                                      hintText: "輸入裝置序號",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => devicesBloc.add(
                                      DevicesToDropDown(),
                                    ),
                                    child: Text(
                                      "取消",
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Values.serial = textEditingController.text;
                                      //resourceBloc.add(ResourceBeforeFetch());
                                      /* Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Devices(),
                                          ),
                                        );*/
                                    },
                                    child: Text(
                                      "確認",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('選擇裝置序號'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BlocProvider(
                                  create: (context) => UploadBloc(),
                                  child: BlocBuilder<UploadBloc, UploadState>(
                                    builder: (context, state){
                                      /*final uploadBloc = BlocProvider.of<UploadBloc>(context);*/
                                      return DropdownButton<String>(
                                        hint: Text("${Values.serial??''}"),
                                        items: devices.map((SerialNumber value) {
                                          return DropdownMenuItem<String>(
                                            value: value.serialNumber,
                                            child: Text(value.serialNumber),
                                          );
                                        },).toList(),
                                        onChanged: (_) {
                                          Values.serial = _;
                                          print("serial:$_");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Setting(),
                                            ),
                                          ).then((value) => setState((){}));
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10,),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context){
                                        return AlertDialog(
                                          title: Text("提醒",),
                                          content: Text(
                                            "假如尚未先建立機台序號的話，執行下列手動新增聲音設定會失敗喔!",
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: (){
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("取消",),
                                            ),
                                            ElevatedButton(
                                              onPressed: (){
                                                devicesBloc.add(DevicesToManual(),);
                                              },
                                              child: Text("確定",),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    "手動新增",
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}