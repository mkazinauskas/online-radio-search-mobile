import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/list.dart';
import 'package:onlineradiosearchmobile/player/audio_state.dart';
import 'package:onlineradiosearchmobile/player/player_widget.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_data_source.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_widget.dart';

class MainWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainWidgetState();
  }
}

class MainWidgetState extends State<MainWidget> {
  final AudioState _audioState = new AudioState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Radio'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                })
          ],
        ),
        body: Column(
            children: <Widget>[
              Expanded(
//            height: 200.0,
            child: PopularStationsWidget(_stationSelectedCallback),
          ),
          (_audioState.hasStation())? PlayerWidget(_audioState): null
        ].where((widget) => widget != null).toList()),
        drawer: Drawer());
  }

  void _stationSelectedCallback(Station newStation){
    setState(() {
      _audioState.setStation(newStation);
    });
  }
}
