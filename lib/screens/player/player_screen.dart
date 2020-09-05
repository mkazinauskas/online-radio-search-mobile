import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
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
      body: SafeArea(
        child: LayoutBuilder(builder: (builder, constraints) {
          return Center(
            child: FutureBuilder(
              future: AudioService.connect(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _loadingView();
                }
                return resolveViewByScreenState(constraints);
              },
            ),
          );
        }),
      ),
      bottomNavigationBar:
          AppBottomNavigationBar(context, PlayerNavigationBarItem()),
    );
  }

  StreamBuilder<ScreenState> resolveViewByScreenState(
      BoxConstraints constraints) {
    return StreamBuilder<ScreenState>(
      stream: _screenStateStream,
      builder: (context, snapshot) {
        ScreenData data = new ScreenData(snapshot);

        if (!AudioService.connected) {
          return _refreshView(context);
        }

        if (!AudioService.running && AudioService.playbackState == null) {
          return _refreshView(context);
        }

        if (data.processingState != AudioProcessingState.ready) {
          return _loadingView();
        }

        var isLandscape = constraints.maxWidth > constraints.maxHeight;
        if (isLandscape) {
          return landscapeView(constraints, data, context);
        } else {
          return portraitView(data, context, constraints);
        }
      },
    );
  }

  Container portraitView(
      ScreenData data, BuildContext context, BoxConstraints constraints) {
    var itemSize = constraints.maxHeight / 3;
    return Container(
      child: Column(
        children: [
          ...[
            Container(
              height: itemSize,
              padding: EdgeInsets.all(20),
              child: Center(
                child: _titleWidget(data.playerItem),
              ),
            ),
            Container(
              height: itemSize,
              padding: EdgeInsets.all(20),
              child: Center(
                child: _statusIndicator(data.playing),
              ),
            ),
            Container(
              height: itemSize,
              padding: EdgeInsets.only(bottom: 50, top: 20),
              child: Center(
                child: buttons(data, context),
              ),
            )
          ],
        ],
      ),
    );
  }

  Container landscapeView(
      BoxConstraints constraints, ScreenData data, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...[
            Container(
                width: constraints.maxWidth / 2,
                child: Stack(
                  children: [
                    Positioned(
                      child: Container(
                          child: Align(
                        alignment: FractionalOffset.topCenter,
                        child: _titleWidget(data.playerItem),
                      )),
                    ),
                    Positioned(
                      child: Container(
                          child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: _statusIndicator(data.playing),
                      )),
                    ),
                  ],
                )),
            Container(
                width: constraints.maxWidth / 2, child: buttons(data, context)),
          ],
        ],
      ),
    );
  }

  Row buttons(ScreenData data, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (data.playerItem != null)
          FavouriteButton(playerItem: data.playerItem),
        if (data.playing) pauseButton() else playButton(),
        stopButton(context),
      ],
    );
  }

  Widget _statusIndicator(bool playing) {
    if (!playing) {
      return Container(
          padding: EdgeInsets.only(top: 30, bottom: 30),
          child: SizedBox.shrink());
    }
    return Container(
      padding: EdgeInsets.all(50),
      child: Image.asset(
        'assets/visualizer.gif',
        color: Colors.white70,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _titleWidget(PlayerItem playerItem) {
    if (playerItem == null) {
      return SizedBox.shrink();
    }

    return Container(
      child: Text(
        playerItem.title,
        style: TextStyle(
            fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
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

  Widget _refreshView(BuildContext context) => Center(
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

  Widget playButton() =>
      _buttonControl(AudioService.play, Icons.play_arrow, Colors.blue);

  Widget pauseButton() =>
      _buttonControl(AudioService.pause, Icons.pause, Colors.blue);

  Widget stopButton(BuildContext context) => _buttonControl(() {
        AudioServiceController.stop();
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.SEARCH, (route) => false);
      }, Icons.stop, Colors.blue);
}

class ScreenData {
  final ScreenState screenState;
  final MediaItem mediaItem;
  final PlayerItem playerItem;
  final PlaybackState playbackState;
  final AudioProcessingState processingState;
  final bool playing;

  ScreenData(AsyncSnapshot<ScreenState> snapshot)
      : screenState = snapshot.data,
        mediaItem = snapshot.data?.mediaItem,
        playerItem = snapshot.data?.mediaItem == null
            ? null
            : PlayerItem.fromJson(
                snapshot.data?.mediaItem?.extras['radioStation']),
        playbackState = snapshot.data?.playbackState,
        processingState = snapshot.data?.playbackState?.processingState ??
            AudioProcessingState.none,
        playing = snapshot.data?.playbackState?.playing ?? false;
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
    FavouritesRepository.findOne(widget.playerItem.id).then(
      (value) => {
        if (value.isPresent)
          {
            this.setState(() {
              _favouriteStationId = value.value.id;
            })
          }
      },
    );
  }

  bool _isFavourite() {
    return _favouriteStationId != null;
  }

  @override
  Widget build(BuildContext context) {
    return _buttonControl(() {
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
    }, Icons.favorite, _isFavourite() ? Colors.pink : Colors.blue);
  }
}

Widget _buttonControl(dynamic action, IconData icon, Color color) {
  return RawMaterialButton(
    onPressed: action,
    elevation: 2.0,
    fillColor: Colors.white,
    child: Icon(
      icon,
      color: color,
      size: 35.0,
    ),
    padding: EdgeInsets.all(15.0),
    shape: CircleBorder(),
  );
}
