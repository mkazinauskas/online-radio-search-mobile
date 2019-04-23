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
//      shape: OutlineInputBorder(),
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
//                        padding: EdgeInsets.all(5.0),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(0, 10.0, 10.0, 10.0),
                        child: Text(_audioState.title(),
                            textAlign: TextAlign.left))),
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
    );
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
