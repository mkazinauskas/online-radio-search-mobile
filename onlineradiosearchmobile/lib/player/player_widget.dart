import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_data_source.dart';

class PlayerWidget extends StatelessWidget {
  final Station _station;
  final AudioPlayer _audioPlayer;

  PlayerWidget(this._audioPlayer, this._station){
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10.0), child: Text(_station.title))
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5.0),
                    child: OutlineButton(
                        onPressed: _playSong,
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                        child: Icon(Icons.play_arrow, size: 40.0),
                        color: Colors.red)),
                Container(
                    padding: EdgeInsets.all(5.0),
                    child: OutlineButton(
                        onPressed: _stopSong,
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

  void _playSong() {
    this._audioPlayer.play(this._station.url);
  }

  void _stopSong() {
    this._audioPlayer.stop();
  }

  void _reset() {
    this._stopSong();
    this._playSong();
  }
}
