import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/radio_player.dart';

class PlayerWidget extends StatefulWidget {

  PlayerWidget();

  @override
  State<StatefulWidget> createState() {
    return PlayerWidgetState();
  }
}

class PlayerWidgetState extends State<PlayerWidget> with WidgetsBindingObserver {

  String _duration = 'Loading...';

  PlayerWidgetState() {
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connect();
  }

  @override
  void dispose() {
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  void connect() async {
    await AudioService.connect();
  }

  void disconnect() {
    AudioService.disconnect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        break;
      case AppLifecycleState.paused:
        disconnect();
        break;
      default:
        break;
    }
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
                        _play(_backgroundAudioPlayerTask);
//                        (false) ? _stop() : _play();
                      },
                      child: (false
                          ? Icon(Icons.pause, size: 30.0)
                          : Icon(Icons.play_arrow, size: 30.0)),
                    )),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(0, 10.0, 10.0, 10.0),
                        child: Row(
                          children: <Widget>[
                            Text('Test',
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
      _duration = '';
    });
  }

  void _play(Function function) {
    AudioService.start(
      backgroundTask: function,
      resumeOnClick: true,
      androidNotificationChannelName: 'Audio Service Demo',
      notificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
    AudioService.play();
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

void _backgroundAudioPlayerTask() async {
  RadioPlayer player = RadioPlayer();
  AudioServiceBackground.run(
    onStart: player.run,
    onPlay: player.play,
    onPause: player.pause,
    onStop: player.stop,
    onClick: (MediaButton button) => player.playPause(),
  );
}