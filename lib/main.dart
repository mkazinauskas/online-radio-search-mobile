import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/screens/main_screen.dart';

void main() => runApp(new OnlineRadioSearchApp());

class OnlineRadioSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Radio Search',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AudioServiceWidget(child: MainScreen())
    );
  }
}

//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Audio Service Demo',
//      theme: ThemeData(primarySwatch: Colors.blue),
//      home: AudioServiceWidget(child: MainScreen()),
//    );
//  }
//}
