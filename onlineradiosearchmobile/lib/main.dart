import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main_widget.dart';
import 'package:onlineradiosearchmobile/player/models_synchroniser.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/popular_stations/radio_stations_model.dart';
import 'package:provider/provider.dart';

void main() {
  return runApp(OnlineRadioSearchApp());
}

class OnlineRadioSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RadioPlayerModel radioPlayerModel = RadioPlayerModel();
    RadioStationsModel popularStationsModel = RadioStationsModel();
    new ModelsSynchroniser(radioPlayerModel, popularStationsModel);

    return MaterialApp(
      title: 'Online Radio',
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (context) => radioPlayerModel),
          ChangeNotifierProvider(builder: (context) => popularStationsModel),
        ],
        child: MainWidget(),
      ),
    );
  }
}
