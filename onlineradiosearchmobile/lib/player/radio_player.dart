import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_data_source.dart';

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

class RadioPlayer {
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  Station _station;

  RadioPlayer();

  Future<void> run() async {
    MediaItem mediaItem = MediaItem(
        id: 'audio_1',
        album: 'Sample Album',
        title: 'Sample Title',
        artist: 'Sample Artist');

    AudioServiceBackground.setMediaItem(mediaItem);

    var playerStateSubscription = _audioPlayer.onPlayerStateChanged
        .where((state) => state == AudioPlayerState.COMPLETED)
        .listen((state) {
      stop();
    });
    play();
    await _completer.future;
    playerStateSubscription.cancel();
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      pause();
    else
      play();
  }

  void play() {
    _audioPlayer.play(_station.url);
    AudioServiceBackground.setState(
      controls: [pauseControl, stopControl],
      basicState: BasicPlaybackState.playing,
    );
  }

  void pause() {
    _audioPlayer.pause();
    AudioServiceBackground.setState(
      controls: [playControl, stopControl],
      basicState: BasicPlaybackState.paused,
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

  void setStation(Station station){
    this._station = station;
  }

  bool hasStation(){
    return _station != null;
  }

  Station station(){
    return _station;
  }
}
