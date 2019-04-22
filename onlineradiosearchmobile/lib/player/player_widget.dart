import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';

class PlayerWidget extends StatelessWidget{

  final _url;

  PlayerWidget(this._url){
    AudioPlayer().stop();
    AudioPlayer().play(_url, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

    );
  }
}

//class PopularStationsWidget extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() {
//    return PopularStationsWidgetState();
//  }
//}


//class PopularStationsWidgetState extends State<PopularStationsWidget> {