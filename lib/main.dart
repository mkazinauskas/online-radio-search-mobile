import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onlineradiosearchmobile/screens/favourites/favourites_screen.dart';
import 'package:onlineradiosearchmobile/screens/player/player_screen.dart';
import 'package:onlineradiosearchmobile/screens/search/discover_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.blue, // navigation bar color
  ));

  runApp(AudioServiceWidget(child: new OnlineRadioSearchApp()));
}

class OnlineRadioSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Radio Search',
      theme: ThemeData(
          primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.blue),
      initialRoute: Routes.SEARCH,
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        Routes.SEARCH: (context) => DiscoverScreen(),
        Routes.FAVOURITES: (context) => FavouritesScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        Routes.PLAYER: (context) => PlayerScreen(),
      },
    );
  }
}

class Routes {
  static final String SEARCH = '/search';
  static final String PLAYER = '/player';
  static final String FAVOURITES = '/favourites';
}
