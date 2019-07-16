import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/radio_player.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:provider/provider.dart';

class PlayerWidget extends StatefulWidget {
  PlayerWidget();

  @override
  State<StatefulWidget> createState() {
    return PlayerWidgetState();
  }
}

class PlayerWidgetState extends State<PlayerWidget>
    with WidgetsBindingObserver {
  PlayerWidgetState() {}

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
                StreamBuilder(
                  stream: AudioService.playbackStateStream,
                  builder: (context, snapshot) {
                    PlaybackState data = snapshot?.data;
                    BasicPlaybackState playerBasicState = data.basicState;

                    if ([
                      BasicPlaybackState.connecting,
                      BasicPlaybackState.playing
                    ].contains(playerBasicState)) {
                      return _pauseButton();
                    } else {
                      return _playButton();
                    }
                  },
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(0, 10.0, 10.0, 10.0),
                        child: Row(
                          children: <Widget>[
                            Consumer<RadioPlayerModel>(
                              builder: (context, model, child) {
                                return Text(model.getTitle(),
                                    textAlign: TextAlign.left);
                              },
                            ),
                            Expanded(
                              child: Consumer<RadioPlayerModel>(
                                builder: (context, model, child) {
                                  return Text(model.getDuration(),
                                      textAlign: TextAlign.right);
                                },
                              ),
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

  Widget _pauseButton() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child:
          GestureDetector(onTap: _pause, child: Icon(Icons.pause, size: 30.0)),
    );
  }

  Widget _playButton() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
          onTap: _play, child: Icon(Icons.play_arrow, size: 30.0)),
    );
  }

  void _pause() {
    AudioService.pause();
  }

  void _play() {
    if (AudioService.playbackState?.basicState == BasicPlaybackState.none ||
        AudioService.playbackState?.basicState == BasicPlaybackState.stopped) {
      AudioService.start(
        backgroundTask: _backgroundAudioPlayerTask,
        resumeOnClick: true,
        androidNotificationChannelName: 'Audio Service Demo',
        notificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
      );
    }
    RadioPlayerModel model =
        Provider.of<RadioPlayerModel>(context, listen: false);
    AudioService.customAction(
        RadioPlayerActions.changeStation.toString(), model.toJson());

    AudioService.play();
  }

  void _durationChanged(Duration duration) {
    setState(() {
//      int totalTimeInSeconds = duration.inSeconds;
//      if (totalTimeInSeconds == 0) {
//        _duration = 'Loading...';
//        return;
//      }
//      String hours = (totalTimeInSeconds ~/ 3600).toString().padLeft(2, '0');
//      String minutes = (totalTimeInSeconds ~/ 60).toString().padLeft(2, '0');
//      String seconds = (totalTimeInSeconds % 60).toString().padLeft(2, '0');
//
//      _duration = "${hours}:${minutes}:${seconds}";
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
    onCustomAction: (String actionName, dynamic data) {
        player.onCustomAction(actionName, data);
    },
  );
}
