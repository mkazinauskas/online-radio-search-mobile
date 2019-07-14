//import 'package:flutter/material.dart';
//import 'package:onlineradiosearchmobile/main_widget.dart';
//
//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Online Radio',
//      home: MainWidget(),
//    );
//  }
//}

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

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
                        audioPlayerButton(),
//                        textToSpeechButton(),
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
  CustomAudioPlayer player = CustomAudioPlayer();
  AudioServiceBackground.run(
    onStart: player.run,
    onPlay: player.play,
    onPause: player.pause,
    onStop: player.stop,
    onClick: (MediaButton button) => player.playPause(),
  );
}

class CustomAudioPlayer {
  static const streamUri =
      'http://5.20.223.18/relaxfm128.mp3';
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  int _position;

  Future<void> run() async {
    MediaItem mediaItem = MediaItem(
        id: 'audio_1',
        album: 'Best radio',
        title: 'Sample Title',
        artist: 'Sample Artist');

    AudioServiceBackground.setMediaItem(mediaItem);

    var playerStateSubscription = _audioPlayer.onPlayerStateChanged
        .where((state) => state == AudioPlayerState.COMPLETED)
        .listen((state) {
      stop();
    });
    var audioPositionSubscription =
    _audioPlayer.onAudioPositionChanged.listen((when) {
      final connected = _position == null;
      _position = when.inMilliseconds;
      if (connected) {
        // After a delay, we finally start receiving audio positions
        // from the AudioPlayer plugin, so we can set the state to
        // playing.
        _setPlayingState();
      }
    });
    play();
    await _completer.future;
    playerStateSubscription.cancel();
    audioPositionSubscription.cancel();
  }

  void _setPlayingState() {
    AudioServiceBackground.setState(
      controls: [pauseControl, stopControl],
      basicState: BasicPlaybackState.playing,
      position: _position,
    );
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      pause();
    else
      play();
  }

  void play() {
    _audioPlayer.play(streamUri);
    if (_position == null) {
      // There may be a delay while the AudioPlayer plugin connects.
      AudioServiceBackground.setState(
        controls: [stopControl],
        basicState: BasicPlaybackState.connecting,
        position: 0,
      );
    } else {
      // We've already connected, so no delay.
      _setPlayingState();
    }
  }

  void pause() {
    _audioPlayer.pause();
    AudioServiceBackground.setState(
      controls: [playControl, stopControl],
      basicState: BasicPlaybackState.paused,
      position: _position,
    );
  }

  void stop() {
    _audioPlayer.stop();
    AudioServiceBackground.setState(
      controls: [],
      basicState: BasicPlaybackState.stopped,
    );
    _completer.complete();
  }
}