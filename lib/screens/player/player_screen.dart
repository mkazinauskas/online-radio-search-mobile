import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:onlineradiosearchmobile/main.dart';
import 'package:onlineradiosearchmobile/screens/app_bottom_navigation_bar.dart';
import 'package:onlineradiosearchmobile/screens/favourites/commands/add_to_favourites_command.dart';
import 'package:onlineradiosearchmobile/screens/favourites/commands/favourites_repository.dart';
import 'package:onlineradiosearchmobile/screens/player/audio_service_controller.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';
import 'package:onlineradiosearchmobile/screens/player/screen_state.dart';
import 'package:rxdart/rxdart.dart';

class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: StreamBuilder<ScreenState>(
          stream: _screenStateStream,
          builder: (context, snapshot) {
            final screenState = snapshot.data;
            final mediaItem = screenState?.mediaItem;
            final playerItem = mediaItem == null
                ? null
                : PlayerItem.fromJson(mediaItem.extras['radioStation']);
            final state = screenState?.playbackState;
            final processingState =
                state?.processingState ?? AudioProcessingState.none;
            final playing = state?.playing ?? false;

            if (!AudioService.running) {
              return _goToSearch(context);
            }

            if (processingState != AudioProcessingState.ready) {
              return _loadingView();
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...[
                  _titleWidget(playerItem),
                  _statusIndicator(playing),
                  SizedBox.fromSize(
                    size: Size.fromHeight(15.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (playerItem != null)
                        FavouriteButton(playerItem: playerItem),
                      if (playing) pauseButton() else playButton(),
                      stopButton(context),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
      bottomNavigationBar:
          AppBottomNavigationBar(context, PlayerNavigationBarItem()),
    );
  }

  Widget _statusIndicator(bool playing) {
    if (!playing) {
      return SizedBox.shrink();
    }
    return Column(children: [
      SizedBox.fromSize(
        size: Size.fromHeight(15.0),
      ),
      SpinKitWave(
        color: Colors.white,
        size: 50.0,
      ),
    ]);
  }

  Widget _titleWidget(PlayerItem playerItem) {
    if (playerItem == null) {
      return SizedBox.shrink();
    }

    return Text(
      playerItem.title,
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState));

  Widget _loadingView() => Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(backgroundColor: Colors.white),
          ],
        ),
      );

  Widget _goToSearch(BuildContext context) => Center(
          child: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            color: Colors.white,
            iconSize: 54,
            icon: Icon(Icons.refresh_sharp),
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.SEARCH, (route) => false),
          ),
        ],
      )));

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        color: Colors.white,
        iconSize: 64.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        color: Colors.white,
        iconSize: 64.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton(BuildContext context) => IconButton(
        icon: Icon(Icons.stop),
        color: Colors.white,
        iconSize: 64.0,
        onPressed: () {
          AudioServiceController.stop().whenComplete(() {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.SEARCH, (route) => false);
          });
        },
      );
}

class FavouriteButton extends StatefulWidget {
  final PlayerItem playerItem;

  FavouriteButton({Key key, this.playerItem}) : super(key: key);

  @override
  _FavouriteButtonState createState() => _FavouriteButtonState(this);
}

class _FavouriteButtonState extends State<FavouriteButton> {
  int _favouriteStationId;

  _FavouriteButtonState(FavouriteButton widget) {
    _findFavouriteId(widget);
  }

  void _findFavouriteId(FavouriteButton widget) {
    FavouritesRepository.findOne(widget.playerItem.id).then((value) => {
          if (value.isPresent)
            {
              this.setState(() {
                _favouriteStationId = value.value.id;
              })
            }
        });
  }

  bool _isFavourite() {
    return _favouriteStationId != null;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.favorite),
      iconSize: 64.0,
      color: _isFavourite() ? Colors.pink : Colors.white,
      onPressed: () {
        if (_isFavourite()) {
          FavouritesRepository.delete(_favouriteStationId).then((value) => {
                this.setState(() {
                  _favouriteStationId = null;
                })
              });
        } else {
          AddToFavouritesHandler()
              .handler(AddToFavouritesCommand(
                widget.playerItem.id,
                widget.playerItem.uniqueId,
                widget.playerItem.title,
                widget.playerItem.streamUrl,
                widget.playerItem.genres,
              ))
              .then((value) => _findFavouriteId(widget));
        }
      },
    );
  }
}
