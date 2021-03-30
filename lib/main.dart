import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_ilolly/blocs/resource/resource_bloc.dart';
import 'package:push_ilolly/blocs/server/server_bloc.dart';
import 'package:push_ilolly/blocs/token/token_bloc.dart';
import 'package:push_ilolly/devices.dart';
import 'package:push_ilolly/values.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();

void backgroundNotificationListener(Map<String, dynamic> data) async {
  print('Received notification: $data');
  await textToSpeech(data['message']);
  String notificationTitle = 'MyApp';
  String notificationText = data['message'] ?? 'Hello World!';
  Pushy.notify(notificationTitle, notificationText, data);
  Pushy.clearBadge();
}

Future<void> textToSpeech(msg) async {
  flutterTts.getVoices.then((value) => print(value));
  await flutterTts.setSpeechRate(1.0);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
  await flutterTts.setLanguage("zh-TW");
  await flutterTts.speak(msg);
  //await flutterTts.setQueueMode(1);
}

Future<void> playMusic(url) async {
  AudioPlayer audioPlayer = AudioPlayer();
  int result = await audioPlayer.play(url);
  if (result == 1) {
    // success
  }
}

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  String _deviceToken = 'Loading...';
  String _instruction = '(please wait)';
  TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> playMusic(url) async {
    AudioPlayer audioPlayer = AudioPlayer();
    int result = await audioPlayer.play(url);
    if (result == 1) {
      // success
    }
  }

  Future<void> initPlatformState() async {
    Pushy.listen();
    try {
      String deviceToken = await Pushy.register();
      print('Device token: $deviceToken');
      setState(() {
        _deviceToken = deviceToken;
        _instruction =
            Platform.isAndroid ? '(copy from logcat)' : '(copy from console)';
      });
    } on PlatformException catch (error) {
      // Print to console/logcat
      print('Error: ${error.message}');

      // Show error
      setState(() {
        _deviceToken = 'Registration failed';
        _instruction = '(restart app to try again)';
      });
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

  Widget settingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              _deviceToken,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            _instruction,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人臉辨識文字轉聲音設置'),
      ),
      body: Builder(
        builder: (context) => BlocProvider(
          create: (context) => TokenBloc(),
          child: BlocBuilder<TokenBloc, TokenState>(
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
                          child: Text('設置'),
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
                    Text('伺服器設置'),
                    MultiBlocProvider(
                      providers: [
                        BlocProvider<ServerBloc>(
                          create: (BuildContext context) => ServerBloc(),
                        ),
                        BlocProvider<ResourceBloc>(
                          create: (BuildContext context) => ResourceBloc(),
                        ),
                      ],
                      child: BlocBuilder<ServerBloc, ServerState>(
                        builder: (context, state) {
                          final serverBloc = BlocProvider.of<ServerBloc>(context);
                          final resourceBloc = BlocProvider.of<ResourceBloc>(context);
                          if (state is ServerFromField) {
                            textEditingController = TextEditingController(text: "http://",);
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
                                          hintText: "輸入伺服器網址",
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
                                        onPressed: () => serverBloc.add(
                                          ServerToDropDown(),
                                        ),
                                        child: Text(
                                          "取消",
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Values.server = textEditingController.text;
                                          //resourceBloc.add(ResourceBeforeFetch());
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Devices(),
                                            ),
                                          );
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
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownButton<String>(
                                items: <String>[
                                  'https://ilolly.shoesconn.com',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },).toList(),
                                onChanged: (_) {
                                  Values.server = _ ;
                                  //resourceBloc.add(ResourceBeforeFetch());
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Devices(),
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 10,),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  serverBloc.add(ServerToManual());
                                },
                                child: Text(
                                  "手動新增",
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return settingWidget();
            },
          ),
        ),
      ),
    );
  }
}
