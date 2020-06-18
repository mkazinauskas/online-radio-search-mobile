import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/screens/favourites/favourites_screen.dart';
import 'package:onlineradiosearchmobile/screens/player/player_screen.dart';
import 'package:onlineradiosearchmobile/screens/search/search_screen.dart';

void main() => runApp(AudioServiceWidget(child: new OnlineRadioSearchApp()));

class OnlineRadioSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Radio Search',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: Routes.SEARCH,
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        Routes.SEARCH: (context) => SearchScreen(),
        Routes.FAVOURITES: (context) => FavouritesScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        Routes.PLAYER: (context) => PlayerScreen(),
      },
    );
  }
}

class Routes {
  static final SEARCH = '/search';
  static final PLAYER = '/player';
  static final FAVOURITES = '/favourites';
}