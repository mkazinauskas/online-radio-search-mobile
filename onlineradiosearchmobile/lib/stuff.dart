import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'player/radio_player.dart';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
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

  void connect() async {
    await AudioService.connect();
  }

  void disconnect() {
    AudioService.disconnect();
  }




  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Audio Service Demo'),
        ),
        body: new Center(
          child: StreamBuilder(
            stream: AudioService.playbackStateStream,
            builder: (context, snapshot) {
              PlaybackState state = snapshot.data;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state?.basicState == BasicPlaybackState.connecting) ...[
                    stopButton(),
                    Text("Connecting..."),
                  ] else
                    if (state?.basicState == BasicPlaybackState.playing) ...[
                      pauseButton(),
                      stopButton(),
                      positionIndicator(state),
                    ] else
                      if (state?.basicState == BasicPlaybackState.paused) ...[
                        playButton(),
                        stopButton(),
                        positionIndicator(state),
                      ] else ...[
                        audioPlayerButton()
                      ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  RaisedButton audioPlayerButton() =>
      startButton('AudioPlayer', _backgroundAudioPlayerTask);

  RaisedButton startButton(String label, Function backgroundTask) =>
      RaisedButton(
        child: Text(label),
        onPressed: () {
          AudioService.start(
            backgroundTask: backgroundTask,
            resumeOnClick: true,
            androidNotificationChannelName: 'Audio Service Demo',
            notificationColor: 0xFF2196f3,
            androidNotificationIcon: 'mipmap/ic_launcher',
          );
        },
      );

  IconButton playButton() => IconButton(
    icon: Icon(Icons.play_arrow),
    iconSize: 64.0,
    onPressed: AudioService.play,
  );

  IconButton pauseButton() => IconButton(
    icon: Icon(Icons.pause),
    iconSize: 64.0,
    onPressed: AudioService.pause,
  );

  IconButton stopButton() => IconButton(
    icon: Icon(Icons.stop),
    iconSize: 64.0,
    onPressed: AudioService.stop,
  );

  Widget positionIndicator(PlaybackState state) => StreamBuilder(
    stream: Observable.periodic(Duration(milliseconds: 200)),
    builder: (context, snapshdot) =>
        Text("${(state.currentPosition / 1000).toStringAsFixed(3)}"),
  );
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
