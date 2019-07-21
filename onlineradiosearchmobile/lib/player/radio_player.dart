import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
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
  RadioPlayerModel _radioPlayerData;

  AudioPlayer _audioPlayer = new AudioPlayer();

  Completer _completer = Completer();

  int _position;

  Future<void> run() async {
    var playerStateSubscription = _audioPlayer.onPlayerStateChanged
        .listen((state) {
          if(state == AudioPlayerState.COMPLETED){
            play();
            return;
          }
          if(state == AudioPlayerState.STOPPED){
            changeBackgroundPlayingItem('Stopped');
            return;
          }
          if(state == AudioPlayerState.PLAYING){
            changeBackgroundPlayingItem('Playing...');
            return;
          }
          if(state == AudioPlayerState.PAUSED){
            changeBackgroundPlayingItem('Paused');
            return;
          }
    });

    playerStateSubscription.onError((error){
      changeBackgroundPlayingItem('Failed to load...');
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
    await _completer.future;

    playerStateSubscription.cancel();
    audioPositionSubscription.cancel();
    AudioServiceBackground.setState(controls: [], basicState: BasicPlaybackState.none);
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
      id: 'audio_1',
      album: status,
      title: _radioPlayerData.getTitle(),
      artist: 'Live',
      artUri: 'https://onlineradiosearch.com/resources/img/common/favicon.png'
    );
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
    _audioPlayer.stop();
    AudioServiceBackground.setState(
      controls: [],
      basicState: BasicPlaybackState.stopped,
    );
    _completer.complete();
  }

  void _changeStation(RadioPlayerModel model) {
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
