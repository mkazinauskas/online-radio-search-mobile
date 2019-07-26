import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/radio_player.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:optional/optional_internal.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class PlayerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PlayerWidgetState();
  }
}

class PlayerWidgetState extends State<PlayerWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
      child: Row(
        children: [
          Expanded(
            child: _stationDisplay(),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: _durationDisplay(),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            child: _displayControlButton(),
          ),
        ],
      ),
    );
  }

  StreamBuilder<PlaybackState> _displayControlButton() {
    return StreamBuilder(
      stream: AudioService.playbackStateStream,
      builder: (context, snapshot) {
        BasicPlaybackState playerBasicState = snapshot?.data?.basicState;

        if ([BasicPlaybackState.connecting, BasicPlaybackState.playing]
            .contains(playerBasicState)) {
          return _pauseButton();
        } else {
          return _playButton();
        }
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

  Widget _stationDisplay() {
    return Consumer<RadioPlayerModel>(
      builder: (context, model, child) {
        _play();
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
      child:
          GestureDetector(onTap: PlayerController.pause, child: Icon(Icons.pause, size: 30.0)),
    );
  }

  Widget _playButton() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
          onTap: _play, child: Icon(Icons.play_arrow, size: 30.0)),
    );
  }

  void _play() {
    var model = Provider.of<RadioPlayerModel>(context);
    model
        .getStation()
        .ifPresent((station) => PlayerController.changeStation(station));
  }
}
