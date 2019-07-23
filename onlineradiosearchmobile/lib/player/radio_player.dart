import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';

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
  static const Duration _secondsBeforeIdleStationRestart =
      Duration(seconds: 15);

  RadioPlayerModel _radioPlayerData;

  AudioPlayer _audioPlayer = new AudioPlayer();

  Completer _completer = Completer();

  DateTime _lastRefresh = new DateTime.now();

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
    });

    var audioPositionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((when) {
      final connected = _position == null;
      if (_position == when.inMilliseconds) {
        if (_audioPlayer.state == AudioPlayerState.PLAYING &&
            _refreshShouldRun()) {
          //Something stuck...
          _lastRefresh = DateTime.now();
          debugPrint("Radio player is in same position!!! `" +
              when.inMilliseconds.toString() +
              "`");
          _audioPlayer.stop();
          play();
        }
      } else {
        _lastRefresh = DateTime.now();
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

  bool _refreshShouldRun() {
    DateTime maxNonRefreshableTime =
        DateTime.now().subtract(_secondsBeforeIdleStationRestart);
    return maxNonRefreshableTime.isAfter(_lastRefresh);
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
    if (_radioPlayerData.getUrl() == '') {
      return;
    }
    changeBackgroundPlayingItem('Connecting...');

//    if (_radioPlayerData.getUrl() != null) {
    _audioPlayer.play(_radioPlayerData.getUrl());
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
    if (_radioPlayerData.getUrl() == '') {
      return;
    }
    MediaItem mediaItem = MediaItem(
        id: _radioPlayerData.getId(),
        album: status,
        title: _radioPlayerData.getTitle(),
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

  void _changeStation(RadioPlayerModel model) {
    if (this._radioPlayerData?.getUrl() == model.getUrl()) {
      if (this._audioPlayer?.state == AudioPlayerState.PLAYING) {
        return;
      }
    }

    this._radioPlayerData = model;

    _audioPlayer.stop();
    play();
  }

  void onCustomAction(String actionName, String data) {
    if (actionName == RadioPlayerActions.changeStation.toString()) {
      _changeStation(RadioPlayerModel.fromData(data));
      return;
    }
    throw new Exception(actionName + ' was not found.');
  }
}
