import 'dart:async';

import 'package:flutter/material.dart';

class Dialogs {

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
