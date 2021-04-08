import 'dart:async';

import 'package:flutter/material.dart';

class Dialogs {

  static Future<bool> showMessageDialog({
    bool success = true,
    BuildContext context,
    String msg,
    Timer timer,
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        timer = Timer(Duration(
          milliseconds: 1500,
        ), () {
          timer.cancel();
          Navigator.of(context).pop();
        });
        return AlertDialog(
          content: Container(
            padding: EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 700,),
                  child: (success)
                      ? Icon(Icons.check_circle_outline,)
                      : Icon(Icons.close,),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(right: 5,),
                    child: Text(
                      '$msg',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showNoNetworkDialog({
    BuildContext context,
    String selectionType,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(
              "無法使用服務",
              style: TextStyle(
                color: Color.fromRGBO(232, 118, 112, 1),
              ),
            ),
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 10,),
                  child: Icon(Icons.wifi_off_outlined),
                ),
                Text("請開啟網路"),
              ],
            ),
          ),
        );
      },
    );
  }

  static final Dialogs _instance = Dialogs._internal();

  factory Dialogs() {
    return _instance;
  }

  Dialogs._internal();
}
