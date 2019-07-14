import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_data_source.dart';
import 'package:provider/provider.dart';

class PopularStationsWidget extends StatefulWidget {

  PopularStationsWidget();

  @override
  State<StatefulWidget> createState() {
    return PopularStationsWidgetState();
  }
}

class PopularStationsWidgetState extends State<PopularStationsWidget> {
  var _stations = List<Station>();

  PopularStationsWidgetState() {
    PopularStationsDataSource().read(_onPopularStationsDownloaded);
  }

  void _onPopularStationsDownloaded(List<Station> stations) {
    setState(() {
      _stations = stations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return items();
  }

  Widget items() {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, i) {
          if (_stations.length == 0 && i == 0) {
            return _loading();
          }
          debugPrint("Index: ${i}");
          if (i < _stations.length) {
            return _buildRow(_stations[i]);
          } else {
            return null;
          }
        });
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
        radioModel.setUrl(station.url);
        radioModel.setTitle(station.title);
      },
      title: Text(station.title, style: TextStyle(fontSize: 18.0)),
    );
  }
}
