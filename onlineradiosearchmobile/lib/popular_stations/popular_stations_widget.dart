import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_model.dart';
import 'package:provider/provider.dart';

import '../station.dart';

class PopularStationsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return items();
  }

  Widget items() {
    return Consumer<PopularStationsModel>(
      builder: (context, popularStationsModel, child) {
        return ListView.separated(
          itemCount: popularStationsModel.stationsCount(),
          separatorBuilder: _separator,
          itemBuilder: (context, i) {
            var stations = popularStationsModel.getStations();
            if (stations.length == 0 && i == 0) {
              return _loading();
            }
            return _row(stations[i], context);
          },
        );
      },
    );
  }

  Widget _separator(context, index) => Divider(
        color: Colors.black26,
        height: 5,
      );

  Widget _loading() {
    return ListTile(
      title: const Text('Loading...', style: TextStyle(fontSize: 18.0)),
    );
  }

  Widget _row(Station station, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
      onTap: () {
        debugPrint("Index: ${station.url}");
        var radioModel = Provider.of<RadioPlayerModel>(context, listen: false);
        radioModel.setId(station.id);
        radioModel.setUrl(station.url);
        radioModel.setTitle(station.title);
      },
      title: Text(station.title, style: TextStyle(fontSize: 18.0)),
      leading: Container(
          padding: EdgeInsets.only(left: 10),
          child:
              Consumer<RadioPlayerModel>(builder: (context, radioModel, child) {
            return Icon(
              Icons.play_arrow,
              size: 30.0,
              color: radioModel.getId() == station.getId()
                  ? Colors.black
                  : Colors.black26,
            );
          })),
    );
  }
}
