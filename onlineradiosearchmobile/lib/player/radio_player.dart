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

enum RadioPlayerActions{
  changeStation
}

class RadioPlayer {

//  final RadioPlayerData _radioPlayerData;
  static const streamUri = 'http://5.20.223.18/relaxfm128.mp3';

  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  int _position;

  RadioPlayer(){
  }
//  RadioPlayer(this._radioPlayerData);

  Future<void> run() async {
//    MediaItem mediaItem = MediaItem(
//        id: 'audio_1',
//        album: 'album',
//        title: 'Sample Title',
//        artist: 'Sample Artist');
//
//    AudioServiceBackground.setMediaItem(mediaItem);

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

  void _changeStation(RadioPlayerModel model){
    MediaItem mediaItem = MediaItem(
        id: 'audio_1',
        album: 'album',
        title: model.getTitle(),
        artist: model.getTitle());

    AudioServiceBackground.setMediaItem(mediaItem);
  }

  void onCustomAction(String actionName, String data) {
      if(actionName == RadioPlayerActions.changeStation.toString()){
        _changeStation(RadioPlayerModel.fromData(data));
        return;
      }
      throw new Exception(actionName + ' was not found.');
  }
}