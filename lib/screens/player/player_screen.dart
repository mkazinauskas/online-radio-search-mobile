import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main.dart';
import 'package:onlineradiosearchmobile/screens/app_bottom_navigation_bar.dart';
import 'package:onlineradiosearchmobile/screens/favourites/commands/add_to_favourites_command.dart';
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
            final queue = screenState?.queue;
            final mediaItem = screenState?.mediaItem;
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
//                  if (queue != null && queue.isNotEmpty)
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: [
//                        IconButton(
//                          icon: Icon(Icons.skip_previous),
//                          iconSize: 64.0,
//                          onPressed: mediaItem == queue.first
//                              ? null
//                              : AudioService.skipToPrevious,
//                        ),
//                        IconButton(
//                          icon: Icon(Icons.skip_next),
//                          iconSize: 64.0,
//                          onPressed: mediaItem == queue.last
//                              ? null
//                              : AudioService.skipToNext,
//                        ),
//                      ],
//                    ),
                  if (mediaItem?.title != null) Text(mediaItem.title),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      favouritesButton(mediaItem.id),
                      if (playing) pauseButton() else playButton(),
                      stopButton(context),
                    ],
                  ),
                  Text("Processing state: " +
                      "$processingState".replaceAll(RegExp(r'^.*\.'), '')),
                  StreamBuilder(
                    stream: AudioService.customEventStream,
                    builder: (context, snapshot) {
                      return Text("custom event: ${snapshot.data}");
                    },
                  ),
                  StreamBuilder<bool>(
                    stream: AudioService.notificationClickEventStream,
                    builder: (context, snapshot) {
                      return Text(
                        'Notification Click Status: ${snapshot.data}',
                      );
                    },
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

  IconButton favouritesButton(String radioStationId) {
    return IconButton(
      icon: Icon(Icons.favorite),
      iconSize: 64.0,
      onPressed: () {
        var currentMediaItemExtras = AudioService.currentMediaItem.extras;
        var item = PlayerItem.fromJson(currentMediaItemExtras['radioStation']);
        AddToFavouritesHandler().handler(AddToFavouritesCommand(
          item.id,
          item.uniqueId,
          item.title,
          item.streamUrl,
          item.genres,
        ));
        print(radioStationId);
      },
    );
  }

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
