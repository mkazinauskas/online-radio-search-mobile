import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/radio_player.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:optional/optional_internal.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class PlayerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: <Widget>[
                _stationDisplay(context),
                _statusDisplay(context)
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: _durationDisplay(),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: _displayControlButton(context),
          ),
        ],
      ),
    );
  }

  StreamBuilder<PlaybackState> _displayControlButton(BuildContext context) {
    return StreamBuilder(
      stream: AudioService.playbackStateStream,
      builder: (context, snapshot) {
        BasicPlaybackState state = snapshot?.data?.basicState;

        Map<BasicPlaybackState, Function> controls = {
          BasicPlaybackState.none: () => _playButton(context),
          BasicPlaybackState.connecting: () => _stopButton(),
          BasicPlaybackState.playing: () => _pauseButton(),
          BasicPlaybackState.paused: () => _playButton(context),
          BasicPlaybackState.stopped: () => _playButton(context),
          BasicPlaybackState.error: () => _playButton(context),
          null: () => _playButton(context),
        };
        var control = controls[state];
        return control();
      },
    );
  }

  Widget _durationDisplay() {
    return StreamBuilder(
      stream: AudioService.playbackStateStream,
      builder: (context, snapshot) {
        PlaybackState state = snapshot.data;
        return StreamBuilder(
          stream: Observable.periodic(Duration(milliseconds: 500)),
          builder: (context, snapshdot) {
            String clock = _durationAsClock(state);
            return Text(clock, textAlign: TextAlign.right);
          },
        );
      },
    );
  }

  String _durationAsClock(PlaybackState state) {
    var totalTimeInSeconds = Optional.ofNullable(state)
        .map((state) => state.currentPosition / 1000)
        .orElse(0.0);

    String hours = (totalTimeInSeconds ~/ 3600).toString().padLeft(2, '0');
    String minutes = (totalTimeInSeconds ~/ 60).toString().padLeft(2, '0');
    String seconds =
        (totalTimeInSeconds % 60).toStringAsFixed(0).padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  Widget _stationDisplay(BuildContext buildContext) {
    return Consumer<RadioPlayerModel>(
      builder: (context, model, child) {
        _play(buildContext);
        return Text(
          model.getStation().map((s) => s.getTitle()).orElse(''),
          textAlign: TextAlign.left,
        );
      },
    );
  }

  Widget _pauseButton() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
          onTap: PlayerController.pause, child: Icon(Icons.pause, size: 30.0)),
    );
  }

  Widget _stopButton() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
          onTap: PlayerController.stop, child: Icon(Icons.stop, size: 30.0)),
    );
  }

  Widget _playButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
          onTap: () => _play(context),
          child: Icon(Icons.play_arrow, size: 30.0)),
    );
  }

  void _play(BuildContext context) {
    var model = Provider.of<RadioPlayerModel>(context);
    model
        .getStation()
        .ifPresent((station) => PlayerController.changeStation(station));
  }

  Widget _statusDisplay(BuildContext context) {
    return StreamBuilder(
      stream: AudioService.playbackStateStream,
      builder: (context, snapshot) {
        BasicPlaybackState state = snapshot?.data?.basicState;
        return Text(
          PlaybackStatus.from(state),
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
