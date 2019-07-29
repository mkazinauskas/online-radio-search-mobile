import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';

import '../station.dart';

class RadioPlayer {
  static const Duration _timeBeforeIdleStationRestart = Duration(seconds: 15);

  static const Duration _timeForNoStationDurationUpdate = Duration(seconds: 8);

  Station _station;

  AudioPlayer _audioPlayer = new AudioPlayer();

  Completer _completer = Completer();

  DateTime _lastRefresh = new DateTime.now();

  DateTime _lastPlayingStarted = new DateTime.now();

  int _position;

  int _timesRestarted;

  Future<void> run() async {
    var playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint("Radio player listen!!! `" + state.toString() + "`");
      if (state == AudioPlayerState.COMPLETED) {
        return;
      }
      if (state == AudioPlayerState.STOPPED) {
        return;
      }
      if (state == AudioPlayerState.PLAYING) {
        _setBackgroundPlayingItem(BasicPlaybackState.playing);
        _timesRestarted = 0;
        return;
      }
      if (state == AudioPlayerState.PAUSED) {
        return;
      }
    });

    playerStateSubscription.onError((error) {
      _setBackgroundPlayingItem(BasicPlaybackState.error);
      _restartStationPlay();
    });

    var audioPositionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((when) {
      if (_position == when.inMilliseconds) {
        _retryPlaying();
      } else {
        _lastPlayingStarted = DateTime.now();
        _position = when.inMilliseconds;
      }
    });
    await _completer.future;

    playerStateSubscription.cancel();
    audioPositionSubscription.cancel();
    AudioServiceBackground.setState(
        controls: [], basicState: BasicPlaybackState.none);
  }

  void _retryPlaying() {
    var state = AudioService.playbackState?.basicState;
    if (state != null && state != BasicPlaybackState.playing) {
      return;
    }
    if (_durationWasNotUpdatedAfterPlayingStarted() && _refreshShouldRun()) {
      _lastRefresh = DateTime.now();
      _restartStationPlay();
    }
  }

  void _restartStationPlay() {
    debugPrint("Radio station is being restarted!!!");
    if(_timesRestarted == 5){
      _setBackgroundPlayingItem(BasicPlaybackState.error);
    }
    _timesRestarted++;
    _setBackgroundPlayingItem(BasicPlaybackState.connecting);
    _audioPlayer.stop();
    play();
  }

  bool _refreshShouldRun() {
    DateTime maxNonRefreshableTime =
        DateTime.now().subtract(_timeBeforeIdleStationRestart);
    return maxNonRefreshableTime.isAfter(_lastRefresh);
  }

  bool _durationWasNotUpdatedAfterPlayingStarted() {
    DateTime maxNonRefreshableTime =
        DateTime.now().subtract(_timeForNoStationDurationUpdate);
    return maxNonRefreshableTime.isAfter(_lastPlayingStarted);
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      pause();
    else
      play();
  }

  void play() {
    if (_station == null) {
      return;
    }

    _setBackgroundPlayingItem(BasicPlaybackState.connecting);

    _audioPlayer.play(_station.getUrl());
  }

  void _setBackgroundPlayingItem(BasicPlaybackState state) {
    MediaItem mediaItem = MediaItem(
        id: _station.id,
        album: PlaybackStatus.from(state),
        title: _station.title,
        artist: 'Live',
        artUri:
            'https://onlineradiosearch.com/resources/img/common/favicon.png');
    AudioServiceBackground.setMediaItem(mediaItem);

    Map<BasicPlaybackState, List<MediaControl>> controls = {
      BasicPlaybackState.connecting: [stopControl],
      BasicPlaybackState.playing: [pauseControl, stopControl],
      BasicPlaybackState.stopped: [],
      BasicPlaybackState.none: [playControl, stopControl],
      BasicPlaybackState.paused: [playControl, stopControl],
    };

    Map<BasicPlaybackState, int> position = {
      BasicPlaybackState.connecting: 0,
      BasicPlaybackState.playing: _position,
      BasicPlaybackState.stopped: 0,
      BasicPlaybackState.none: 0,
      BasicPlaybackState.paused: _position,
    };
    AudioServiceBackground.setState(
      controls: controls[state],
      basicState: state,
      position: position[state],
    );
  }

  void pause() {
    _setBackgroundPlayingItem(BasicPlaybackState.paused);
    _audioPlayer.pause();
  }

  void stop() {
    _setBackgroundPlayingItem(BasicPlaybackState.stopped);
    _audioPlayer.stop();
    _completer.complete();
  }

  void _changeStation(Station station) {
    if (this._station != null &&
        _station.equals(station) &&
        this._audioPlayer?.state == AudioPlayerState.PLAYING) {
      return;
    }

    this._station = station;
    this._position = 0;

    _audioPlayer.stop();
    play();
  }

  void onCustomAction(String actionName, String data) {
    if (actionName == RadioPlayerActions.changeStation.toString()) {
      _changeStation(Station.fromJson(data));
      return;
    }
    throw new Exception(actionName + ' was not found.');
  }
}

class PlayerController {
  static void changeStation(Station station) async {
    if (await AudioService.running != true) {
      await AudioService.start(
        backgroundTask: _backgroundAudioPlayerTask,
        resumeOnClick: true,
        androidNotificationChannelName: 'Online Radio Player',
        notificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
      );
    }
    AudioService.running.whenComplete(() {
      AudioService.customAction(
          RadioPlayerActions.changeStation.toString(), station.toJson());
    });
  }

  static void stop() {
    AudioService.stop();
  }

  static void pause() {
    AudioService.pause();
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

class PlaybackStatus {
  static final Map<BasicPlaybackState, String> _messages = {
    BasicPlaybackState.paused: 'Paused',
    BasicPlaybackState.error: 'Error while playing...',
    BasicPlaybackState.playing: 'Playing...',
    null: 'Ready',
    BasicPlaybackState.none: 'Ready',
    BasicPlaybackState.stopped: 'Stopped',
    BasicPlaybackState.connecting: 'Connecting...'
  };

  static String from(BasicPlaybackState state) {
    return _messages[state];
  }
}

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

enum RadioPlayerActions { changeStation }
