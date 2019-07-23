import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_model.dart';
import 'package:provider/provider.dart';

import '../station.dart';

class PopularStationsWidget extends StatefulWidget {
  PopularStationsWidget();

  @override
  State<StatefulWidget> createState() {
    return PopularStationsWidgetState();
  }
}

class PopularStationsWidgetState extends State<PopularStationsWidget> {
  @override
  Widget build(BuildContext context) {
    return items();
  }

  Widget items() {
    return Consumer<PopularStationsModel>(
      builder: (context, popularStationsModel, child) {
        return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (context, i) {
              var stations = popularStationsModel.getStations();
              if (stations.length == 0 && i == 0) {
                return _loading();
              }
              if (i < stations.length) {
                return _buildRow(stations[i]);
              } else {
                return null;
              }
            });
      },
    );
  }

  Widget _loading() {
    return ListTile(
      title: Text('Loading...', style: TextStyle(fontSize: 18.0)),
    );
  }

  Widget _buildRow(Station station) {
    return ListTile(
      onTap: () {
        debugPrint("Index: ${station.url}");
        var radioModel = Provider.of<RadioPlayerModel>(context, listen: false);
        radioModel.setId(station.id);
        radioModel.setUrl(station.url);
        radioModel.setTitle(station.title);
      },
      title: Text(station.title, style: TextStyle(fontSize: 18.0)),
    );
  }
}
