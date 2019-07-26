import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';

import '../station.dart';

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

class RadioPlayer {
  static const Duration _timeBeforeIdleStationRestart = Duration(seconds: 15);

  static const Duration _timeForNoStationDurationUpdate = Duration(seconds: 5);

  Station _station;

  AudioPlayer _audioPlayer = new AudioPlayer();

  Completer _completer = Completer();

  DateTime _lastRefresh = new DateTime.now();

  DateTime _lastDurationUpdate = new DateTime.now();

  int _position;

  Future<void> run() async {
    var playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint("Radio player listen!!! `" + state.toString() + "`");
      if (state == AudioPlayerState.COMPLETED) {
        play();
        return;
      }
      if (state == AudioPlayerState.STOPPED) {
        return;
      }
      if (state == AudioPlayerState.PLAYING) {
        changeBackgroundPlayingItem('Playing...');
        return;
      }
      if (state == AudioPlayerState.PAUSED) {
        changeBackgroundPlayingItem('Paused');
        return;
      }
    });

    playerStateSubscription.onError((error) {
      changeBackgroundPlayingItem('Failed to load...');
      _retryPlaying(true);
    });

    var audioPositionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((when) {
      final connected = _position == null;
      if (_position == when.inMilliseconds) {
        _retryPlaying(false);
      } else {
        _lastDurationUpdate = DateTime.now();
        _position = when.inMilliseconds;
      }

      if (connected) {
        // After a delay, we finally start receiving audio positions
        // from the AudioPlayer plugin, so we can set the state to
        // playing.
        _setPlayingState();
      }
    });
    await _completer.future;

    playerStateSubscription.cancel();
    audioPositionSubscription.cancel();
    AudioServiceBackground.setState(
        controls: [], basicState: BasicPlaybackState.none);
  }

  void _retryPlaying(bool force) {
    if ((_audioPlayer.state == AudioPlayerState.PLAYING || force) &&
        _durationWasNotUpdated() &&
        _refreshShouldRun()) {
      //Something stuck...
      _lastRefresh = DateTime.now();
      debugPrint("Radio station is being restarted!!!");
      _audioPlayer.stop();
      play();
    }
  }

  bool _refreshShouldRun() {
    DateTime maxNonRefreshableTime =
        DateTime.now().subtract(_timeBeforeIdleStationRestart);
    return maxNonRefreshableTime.isAfter(_lastRefresh);
  }

  bool _durationWasNotUpdated() {
    DateTime maxNonRefreshableTime =
        DateTime.now().subtract(_timeForNoStationDurationUpdate);
    return maxNonRefreshableTime.isAfter(_lastDurationUpdate);
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
    if (_station == null) {
      return;
    }
    changeBackgroundPlayingItem('Connecting...');

//    if (_radioPlayerData.getUrl() != null) {
    _audioPlayer.play(_station.getUrl());
//    }
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

  void changeBackgroundPlayingItem(String status) {
    if (_station == null) {
      return;
    }
    MediaItem mediaItem = MediaItem(
        id: _station.id,
        album: status,
        title: _station.title,
        artist: 'Live',
        artUri:
            'https://onlineradiosearch.com/resources/img/common/favicon.png');
    AudioServiceBackground.setMediaItem(mediaItem);
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
    changeBackgroundPlayingItem('Stopped');
    _audioPlayer.stop();
    AudioServiceBackground.setState(
      controls: [],
      basicState: BasicPlaybackState.stopped,
    );
    _completer.complete();
  }

  void _changeStation(Station station) {
    if (this._station != null &&
        _station.equals(station) &&
        this._audioPlayer?.state == AudioPlayerState.PLAYING) {
      return;
    }

    this._station = station;

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
