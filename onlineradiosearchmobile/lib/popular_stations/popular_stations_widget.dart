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
        var loadingState = popularStationsModel.loadingState();

        if (loadingState == PopularStationsLoadingState.NONE) {
          return _message('Loading...');
        }

        if (loadingState == PopularStationsLoadingState.ERROR) {
          return _retryLoad(
              'Error while fetching data. Please check internet connection',
              popularStationsModel,
              context);
        }

        if (loadingState == PopularStationsLoadingState.COMPLETE &&
            popularStationsModel.stationsCount() == 0) {
          return _retryLoad('No stations are currently available.',
              popularStationsModel, context);
        }

        return _displayItems(context, popularStationsModel);
      },
    );
  }

  Widget _displayItems(BuildContext context, PopularStationsModel model) {
    return ListView.separated(
      itemCount: model.stationsCount(),
      separatorBuilder: _separator,
      itemBuilder: (context, i) {
        var stations = model.getStations();
        return _row(stations[i], context);
      },
    );
  }

  Widget _separator(context, index) => Divider(
        color: Colors.black26,
        height: 5,
      );

  Widget _message(String message) {
    return Center(
      child: Text(message, style: TextStyle(fontSize: 18.0)),
    );
  }

  Widget _row(Station station, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
      onTap: () {
        debugPrint("Index: ${station.url}");
        var radioModel = Provider.of<RadioPlayerModel>(context, listen: false);
        radioModel.setStation(station);
      },
      title: Text(station.title, style: TextStyle(fontSize: 18.0)),
      leading: Container(
          padding: EdgeInsets.only(left: 10),
          child:
              Consumer<RadioPlayerModel>(builder: (context, radioModel, child) {
            return Icon(
              Icons.play_arrow,
              size: 30.0,
              color: radioModel
                      .getStation()
                      .filter((s) => station.equals(s))
                      .isPresent
                  ? Colors.black
                  : Colors.black26,
            );
          })),
    );
  }

  Widget _retryLoad(
      String message, PopularStationsModel model, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          message,
          style: TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
        IconButton(
            padding: EdgeInsets.all(10),
            iconSize: 40.0,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh',
            onPressed: model.downloadData),
      ],
    );
  }
}
