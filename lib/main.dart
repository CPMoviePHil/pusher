import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_ilolly/blocs/application/application_bloc.dart';
import 'package:push_ilolly/blocs/resource/resource_bloc.dart';
import 'package:push_ilolly/blocs/server/server_bloc.dart';
import 'package:push_ilolly/blocs/token/token_bloc.dart';
import 'package:push_ilolly/choices.dart';
import 'package:push_ilolly/configs/configs.dart';
import 'package:push_ilolly/prefs/utils.dart';
import 'package:push_ilolly/values.dart';
import 'package:push_ilolly/utils/utils.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/devices/devices_bloc.dart';
import 'blocs/observer.dart';
import 'blocs/upload/upload_bloc.dart';

import 'package:http/http.dart' as http;

FlutterTts flutterTts = FlutterTts();
StreamController notifyStream = StreamController();
void backgroundNotificationListener(Map<String, dynamic> data) async {
  await textToSpeech(data['message']);
  String notificationTitle = 'MyApp';
  String notificationText = data['message'] ?? 'Hello World!';
  Pushy.notify(notificationTitle, notificationText, data);
  Pushy.clearBadge();
}

Future<void> textToSpeech(msg) async {
  //flutterTts.getVoices.then((value) => print(value));
  if (Values.waiting) {
    await flutterTts.setQueueMode(1);
  }
  if (!Values.waiting) {
    await flutterTts.setQueueMode(0);
    //await flutterTts.;
    //flutterTts.awaitSpeakCompletion(false);
  }
  await flutterTts.setSpeechRate(1.0);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
  await flutterTts.setLanguage("en-US");
  await flutterTts.speak(msg);
  //await flutterTts.awaitSpeakCompletion(Values.waiting);
}

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ApplicationBloc>(
          create: (BuildContext context) => ApplicationBloc(),
        ),
        BlocProvider<UploadBloc>(
          create: (BuildContext context) => UploadBloc(),
        ),
        BlocProvider<TokenBloc>(
          create: (BuildContext context) => TokenBloc(
            applicationBloc: BlocProvider.of<ApplicationBloc>(context),
            uploadBloc: BlocProvider.of<UploadBloc>(context),
          ),
        ),
        BlocProvider<ServerBloc>(
          create: (BuildContext context) => ServerBloc(),
        ),
        BlocProvider<ResourceBloc>(
          create: (BuildContext context) => ResourceBloc(),
        ),
        BlocProvider<DevicesBloc>(
          create: (context) => DevicesBloc(),
        ),
      ],
      child: Main(),
    ),
  );
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      title: 'Pushy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Light theme with dark action bar
        brightness: Brightness.light,
        primaryColor: Colors.grey[900],
        accentColor: Colors.redAccent,
      ),
      home: PushyDemo(),
    );
  }
}

class PushyDemo extends StatefulWidget {
  @override
  _PushyDemoState createState() => _PushyDemoState();
}

class _PushyDemoState extends State<PushyDemo> {
  TextEditingController textEditingController;
  NetworkConnectionStatus connect = NetworkConnectionStatus.instance;

  @override
  void initState() {
    super.initState();
    connect.init();
    connect.myStream.listen((event) {
      if (!event['networkStatus']) {
        Dialogs.showNoNetworkDialog(
          context: context,
        );
        connect.changeStatus(-1);
      } else {
        if (connect.first == -1) {
          connect.changeStatus(0);
          Navigator.of(context).pop();
          setState(() {

          });
        }
      }
    });
    initPlatformState();
    BlocProvider.of<TokenBloc>(context);
    Future.delayed(Duration(seconds: 2)).then((value) {
      final appBloc = BlocProvider.of<ApplicationBloc>(context);
      appBloc.add(BeforeGetApplicationEvent());
    });
  }

  Future<void> initPlatformState() async {
    Pushy.listen();
    try {
      String deviceToken = await Pushy.register();
      print('Device token: $deviceToken');
      Values.deviceToken = deviceToken;
    } on PlatformException catch (error) {
      // Print to console/logcat
      print('Error: ${error.message}');
    }
    Pushy.setNotificationListener(backgroundNotificationListener);
    Pushy.setNotificationClickListener((Map<String, dynamic> data) {
      print('Notification clicked: $data');
      String message = data['message'] ?? 'Hello World!';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Notification clicked'),
            content: Text(message),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ),
            ],
          );
        },
      );
      Pushy.clearBadge();
    });
  }

  Future<void> testTTS({
    String msg = '?????????????????????',
  }) async {
    Uri notifyUri = Uri.parse(Configs.pushyUri + Configs.pushyKey);
    await http.post(
      notifyUri,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "to": "${Values.deviceToken}",
          "data": {
            "message": "$msg",
          },
          "notification": {"body": "Hello World \u270c", "badge": 1}
        },
      ),
    );
  }

  Widget settingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "????????????:${Values.appVersion}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "????????????:${Values.server}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "????????????:${Values.serial}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Device Token:${Values.deviceToken}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "????????????:${Values.waiting?'??????':'?????????'}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      TextEditingController controller =
                          TextEditingController();
                      await showDialog<void>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                '?????????????????????',
                              ),
                              content: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: '??????????????????',
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await testTTS();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    '????????????',
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await testTTS(
                                      msg: controller.text,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    '??????',
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    child: Text(
                      "?????????????????????",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool result = await showDialog<bool>(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("????????????"),
                            content: Text("??????????????????????????????"),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text("?????????"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text("??????"),
                              ),
                            ],
                          );
                        },
                      );
                      Values.waiting = result;
                      Prefs.preferences = await SharedPreferences.getInstance();
                      Prefs.preferences.setBool("waiting", Values.waiting,);
                      setState(() {

                      });
                    },
                    child: Text(
                      "????????????",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool result = await showDialog<bool>(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("????????????"),
                            content: Text("???????????????????"),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text("??????"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text("??????"),
                              ),
                            ],
                          );
                        },
                      );
                      if (result) {
                        try {
                          Uri uri = Uri.parse(
                            Values.server + Configs.uploadDeviceTokenApi,
                          );
                          final data = await http.post(
                            uri,
                            headers: <String, String>{
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode({
                              "serial_number": Values.serial,
                              "device_token": null,
                            },),
                          );
                          TokenBloc tokenBloc = BlocProvider.of<TokenBloc>(context);
                          if (data.statusCode == 200) {
                            if (json.decode(data.body)['result']) {
                              Prefs.preferences = await SharedPreferences.getInstance();
                              Prefs.preferences.clear();
                              //Values.deviceToken = '';
                              Values.serial = null;
                              Values.server = null;
                              Values.ttsSetting = null;
                              Values.waiting = null;
                              tokenBloc.add(NeedToSetToken());
                            } else {
                              Dialogs.showMessageDialog(
                                success: false,
                                context: context,
                                msg: '????????????????????????????????????',
                              );
                            }
                          } else {
                            Dialogs.showMessageDialog(
                              success: false,
                              context: context,
                              msg: '????????????????????????????????????',
                            );
                          }
                        } catch(e) {
                          print("error:$e");
                          Dialogs.showMessageDialog(
                            success: false,
                            context: context,
                            msg: '????????????????????????????????????',
                          );
                        }
                      }
                    },
                    child: Text(
                      "????????????",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('????????????'),
              content: Text("??????????????????????"),
              actionsPadding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              actions: [
                ElevatedButton(
                  child: Text('??????'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: Text('??????'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('??????????????????'),
        ),
        body: BlocBuilder<ApplicationBloc, ApplicationState>(
          builder: (context, state) {
            if (state is ApplicationSetupCompleted) {
              return BlocBuilder<TokenBloc, TokenState>(
                builder: (context, state) {
                  final tokenBloc = BlocProvider.of<TokenBloc>(context);
                  if (state is TokenInitial) {
                    return Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                tokenBloc.add(ToSetToken());
                              },
                              child: Text('??????'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is TokenSetting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('???????????????'),
                        BlocBuilder<ServerBloc, ServerState>(
                          builder: (context, state) {
                            final serverBloc =
                                BlocProvider.of<ServerBloc>(context);
                            if (state is ServerFromField) {
                              if (Values.server == null) {
                                textEditingController = TextEditingController(
                                  text: "https://",
                                );
                              } else {
                                textEditingController = TextEditingController(
                                  text: "${Values.server}",
                                );
                              }
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: TextField(
                                          controller: textEditingController,
                                          decoration: InputDecoration(
                                            hintText: "?????????????????????",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => serverBloc.add(
                                            ServerToDropDown(),
                                          ),
                                          child: Text(
                                            "??????",
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Values.server =
                                                textEditingController.text;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Choice(),
                                              ),
                                            ).then((value) => setState(() {}));
                                          },
                                          child: Text(
                                            "??????",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DropdownButton<String>(
                                  hint: Text('${Values.server ?? ''}'),
                                  items: <String>[
                                    'https://ilolly.shoesconn.com',
                                  ].map(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (_) {
                                    Values.server = _;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Choice(),
                                      ),
                                    ).then((value) => setState(() {}));
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 10,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    serverBloc.add(ServerToManual());
                                  },
                                  child: Text(
                                    "????????????",
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  }
                  return settingWidget();
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    ApplicationBloc applicationBloc = BlocProvider.of<ApplicationBloc>(context);
    TokenBloc tokenBloc = BlocProvider.of<TokenBloc>(context);
    UploadBloc uploadBloc = BlocProvider.of<UploadBloc>(context);
    ServerBloc serverBloc = BlocProvider.of<ServerBloc>(context);
    ResourceBloc resourceBloc = BlocProvider.of<ResourceBloc>(context);
    DevicesBloc devicesBloc = BlocProvider.of<DevicesBloc>(context);
    applicationBloc.close();
    tokenBloc.close();
    uploadBloc.close();
    serverBloc.close();
    resourceBloc.close();
    devicesBloc.close();
    connect.disposeStream();
    super.dispose();
  }
}
