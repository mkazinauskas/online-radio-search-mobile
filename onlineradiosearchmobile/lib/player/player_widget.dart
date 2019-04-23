import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/audio_state.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_data_source.dart';

class PlayerWidget extends StatelessWidget {

  final AudioState _audioState;

  PlayerWidget(this._audioState);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10.0), child: Text(_audioState.title()))
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5.0),
                    child: OutlineButton(
                        onPressed: _audioState.play,
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                        child: Icon(Icons.play_arrow, size: 40.0),
                        color: Colors.red)),
                Container(
                    padding: EdgeInsets.all(5.0),
                    child: OutlineButton(
                        onPressed: _audioState.stop,
                       padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                        child: Icon(Icons.stop, size: 40.0), color: Colors.teal)),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
