import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'devices.dart';

class Choice extends StatefulWidget {

  @override
  _ChoicePage createState() => _ChoicePage();

}
class _ChoicePage extends State<Choice>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '設置選擇',
        ),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*ElevatedButton(
                onPressed: null,
                child: Text("設置裝置序號(功能尚未建立)"),
              ),*/
              Padding(
                padding: EdgeInsets.only(top: 30,),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Devices(),
                  ),
                ),
                child: Text("設置文字轉聲音設置"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}