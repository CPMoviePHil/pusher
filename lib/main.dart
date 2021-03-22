import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();

void backgroundNotificationListener(Map<String, dynamic> data) async {
  // Print notification payload data
  print('Received notification: $data');

  await textToSpeech(data['message']);

  //playMusic(data['text_to_music']);
  // Notification title
  String notificationTitle = 'MyApp';

  // Attempt to extract the "message" property from the payload: {"message":"Hello World!"}
  String notificationText = data['message'] ?? 'Hello World!';

  // Android: Displays a system notification
  // iOS: Displays an alert dialog
  Pushy.notify(notificationTitle, notificationText, data);

  // Clear iOS app badge number
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

// Please place this code in main.dart,
// After the import statements, and outside any Widget class (top-level)



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

  // Platform messages are asynchronous, so we initialize in an async method
  Future<void> initPlatformState() async {
    // Start the Pushy service
    Pushy.listen();

    try {
      // Register the device for push notifications
      String deviceToken = await Pushy.register();

      // Print token to console/logcat
      print('Device token: $deviceToken');

      // Send the token to your backend server
      // ...

      // Update UI with token
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

    // Listen for push notifications received
    Pushy.setNotificationListener(backgroundNotificationListener);

    // Listen for push notification clicked
    Pushy.setNotificationClickListener((Map<String, dynamic> data) {
      // Print notification payload data
      print('Notification clicked: $data');

      // Extract notification messsage
      String message = data['message'] ?? 'Hello World!';

      // Display an alert with the "message" payload value
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
                )
              ]);
        },
      );

      // Clear iOS app badge number
      Pushy.clearBadge();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Demo app UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pushy'),
      ),
      body: Builder(
        builder: (context) => Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(_deviceToken,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey[700])),
                  ),
                  Text(_instruction,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ])),
      ),
    );
  }
}
