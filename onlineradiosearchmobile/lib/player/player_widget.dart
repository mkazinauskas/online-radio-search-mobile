import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/audio_state.dart';

class PlayerWidget extends StatefulWidget {
  final _audioState;

  PlayerWidget(this._audioState);

  @override
  State<StatefulWidget> createState() {
    return PlayerWidgetState(_audioState);
  }
}

class PlayerWidgetState extends State<PlayerWidget> {
  final AudioState _audioState;

  String _duration = 'Loading...';

  PlayerWidgetState(this._audioState) {
    _audioState.setDurationListener(this._durationChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        (_audioState.isPlaying()) ? _stop() : _play();
                      },
                      child: (_audioState.isPlaying()
                          ? Icon(Icons.pause, size: 30.0)
                          : Icon(Icons.play_arrow, size: 30.0)),
                    )),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(0, 10.0, 10.0, 10.0),
                        child: Row(
                          children: <Widget>[
                            Text(_audioState.title(),
                                textAlign: TextAlign.left),
                            Expanded(
                              child:
                                  Text(_duration, textAlign: TextAlign.right),
                            ),
                          ],
                        )))
              ],
            )
          ],
        ),
      ),
    );
  }

  void _stop() {
    setState(() {
      _audioState.stop();
      _duration = '';
    });
  }

  void _play() {
    setState(() {
      _audioState.play();
      _duration = 'Loading...';
    });
  }

  void _durationChanged(Duration duration) {
    setState(() {
      int totalTimeInSeconds = duration.inSeconds;
      if (totalTimeInSeconds == 0) {
        _duration = 'Loading...';
        return;
      }
      String hours = (totalTimeInSeconds ~/ 3600).toString().padLeft(2, '0');
      String minutes = (totalTimeInSeconds ~/ 60).toString().padLeft(2, '0');
      String seconds = (totalTimeInSeconds % 60).toString().padLeft(2, '0');

      _duration = "${hours}:${minutes}:${seconds}";
    });
  }
}
