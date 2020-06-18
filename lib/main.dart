import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/MainScreen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AudioServiceWidget(child: MainScreen()),
    );
  }
}
