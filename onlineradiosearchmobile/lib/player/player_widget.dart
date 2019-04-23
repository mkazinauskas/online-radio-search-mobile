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

  PlayerWidgetState(this._audioState);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    child: IconButton(
                        onPressed: () {
                          (_audioState.isPlaying()) ? _stop() : _play();
                        },
                        tooltip: 'Increase volume by 10',
                        icon: (_audioState.isPlaying()
                            ? Icon(Icons.pause, size: 30.0)
                            : Icon(Icons.play_arrow, size: 30.0)),
//                        padding: EdgeInsets.all(5.0),
                        color: Colors.black)),
                Expanded(child: Text(_audioState.title(), textAlign: TextAlign.center)),
//                Container(
//                    child: IconButton(
//                        onPressed: () {},
//                        icon: Icon(Icons.favorite),
////                        padding: EdgeInsets.all(5.0),
//                        color: Colors.black))
              ],
            )
          ],
        ),
      ),
    ));
  }

  void _stop() {
    setState(() {
      _audioState.stop();
    });
  }

  void _play() {
    setState(() {
      _audioState.play();
    });
  }
}
