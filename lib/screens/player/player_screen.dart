import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:onlineradiosearchmobile/main.dart';
import 'package:onlineradiosearchmobile/screens/app_bottom_navigation_bar.dart';
import 'package:onlineradiosearchmobile/screens/favourites/commands/add_to_favourites_command.dart';
import 'package:onlineradiosearchmobile/screens/favourites/commands/favourites_repository.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';
import 'package:onlineradiosearchmobile/screens/player/screen_state.dart';
import 'package:rxdart/rxdart.dart';

class PlayerScreen extends StatelessWidget {
  /// Tracks the position while the user drags the seek bar.
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player'),
      ),
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

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (processingState == AudioProcessingState.none) ...[
                  loadingView(),
                ] else ...[
                  Align(
                      child: mediaItem?.title != null
                          ? Text(
                              mediaItem.title,
                              style: TextStyle(
                                fontSize: 32.0,
                              ),
                            )
                          : null),
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

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState));

  Widget loadingView() => Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text(
              "  Loading...",
              textAlign: TextAlign.center,
            )
          ],
        ),
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

  IconButton stopButton(BuildContext context) => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.SEARCH, (route) => false);
          AudioService.stop();
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
      color: _isFavourite() ? Colors.pink : Colors.black,
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
