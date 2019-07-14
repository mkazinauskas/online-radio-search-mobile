import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Radio',
      home: MainWidget(),
    );
  }
}