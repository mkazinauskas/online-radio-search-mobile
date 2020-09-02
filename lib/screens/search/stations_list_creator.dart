import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main.dart';
import 'package:onlineradiosearchmobile/screens/alert.dart';
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/api/streams_client.dart';
import 'package:onlineradiosearchmobile/screens/player/audio_service_controller.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';

class StationsListCreator {
  static Card createTile(Station station, BuildContext context, dynamic backAction) {
    var genres = '';
    if (station.genres.isNotEmpty) {
      genres = ' - ' + station.genres.map((genre) => genre.title).join(', ');
    }

    var currentItem = AudioService.currentMediaItem;
    bool enabled = true;
    if (currentItem != null) {
      var playerItem = PlayerItem.fromJson(currentItem.extras['radioStation']);
      if (playerItem.id == station.id.toString()) {
        enabled = false;
      }
    }

    Widget subtitle;
    if (station.website != null && station.website != '') {
      subtitle = Row(children: <Widget>[
        Flexible(
          child: Text(
            station.website,
            style: TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]);
    }

    return Card(
      elevation: 10.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration:
            BoxDecoration(color: enabled ? Colors.blue : Colors.lightBlue),
        child: ListTile(
          enabled: enabled,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//          leading: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: [
//                Container(
//                  padding: EdgeInsets.only(right: 12.0),
//                  decoration: new BoxDecoration(
//                    border: new Border(
//                      right: new BorderSide(width: 1.0, color: Colors.white24),
//                    ),
//                  ),
//                  child: Icon(Icons.favorite, color: Colors.white),
//                )
//              ]),
          title: Text(
            station.title + genres,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: subtitle,
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
          onTap: () {
            StreamsClient((List<StreamResponse> response, ApiState state) {
              if (state == ApiState.COMPLETE) {
                response.retainWhere((element) => element.working);
                if (response.isEmpty) {
                  Alert.show(context, 'No working stream found.');
                  return;
                }
                List<String> genres = station.genres.length > 0
                    ? List<String>.from(
                        station.genres.map((e) => e.title).toList())
                    : [];
                var item = PlayerItem(
                  station.id.toString(),
                  station.uniqueId,
                  station.title,
                  response[0].url,
                  genres,
                );
                AudioServiceController.changeStation(item);
                Navigator.pushNamed(context, Routes.PLAYER)
                .then((value) => backAction());
              } else {
                Alert.show(context, 'Failed to load data.');
              }
            })?.load(station.id);
          },
        ),
      ),
    );
  }
}
