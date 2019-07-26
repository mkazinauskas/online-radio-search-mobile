import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main_widget.dart';
import 'package:onlineradiosearchmobile/player/models_synchroniser.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_model.dart';
import 'package:provider/provider.dart';

void main() {
  RadioPlayerModel radioPlayerModel = RadioPlayerModel();
  PopularStationsModel popularStationsModel = PopularStationsModel();
  new ModelsSynchroniser(radioPlayerModel, popularStationsModel);
  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => radioPlayerModel),
        ChangeNotifierProvider(builder: (context) => popularStationsModel),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Radio',
      home: MainWidget(),
    );
  }
}
