import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main_widget.dart';
import 'package:onlineradiosearchmobile/player/background_service_model.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_model.dart';
import 'package:provider/provider.dart';

RadioPlayerModel radioPlayerModel = RadioPlayerModel();
PopularStationsModel popularStationsModel = PopularStationsModel();
BackgroundServiceModel backgroundServiceModel = new BackgroundServiceModel(radioPlayerModel,popularStationsModel);

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (context) => radioPlayerModel),
          ChangeNotifierProvider(builder: (context) => popularStationsModel),
          ChangeNotifierProvider(builder: (context) => backgroundServiceModel),
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Radio',
      home: MainWidget(),
    );
  }
}
