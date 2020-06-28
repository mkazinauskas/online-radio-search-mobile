import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onlineradiosearchmobile/main.dart';
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/api/streams_client.dart';
import 'package:onlineradiosearchmobile/screens/player/audio_service_controller.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';

class StationsListCreator {
  static ListTile createTile(Station station, BuildContext context) {
    var genres = '';
    if (station.genres.isNotEmpty) {
      genres = ' - ' + station.genres.map((genre) => genre.title).join(', ');
    }
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        title: Row(children: [
          Flexible(
            child: Text(
              station.title + genres,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              overflow: TextOverflow.fade,
            ),
          ),
        ]),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
//            Icon(Icons.linear_scale, color: Colors.black),
            Flexible(
              child: Text(
                station.website == null ? "" : station.website,
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onTap: () {
          StreamsClient((List<StreamResponse> response, ApiState state) {
            if (state == ApiState.COMPLETE) {
              response.retainWhere((element) => element.working);
              if (response.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'No working stream found.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                );
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
              Navigator.pushNamed(context, Routes.PLAYER);
            } else {
              Fluttertoast.showToast(
                msg: 'Failed to load data.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            }
          }).load(station.id);
        },
        trailing:
            Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0));
  }
}
