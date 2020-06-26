import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/api/streams_client.dart';
import 'package:onlineradiosearchmobile/screens/player/audio_service_controller.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';

import '../../main.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 1) {
      return emptyQueryMessage();
    }

    var result = StationsClient(() {}).search(query);

    return FutureBuilder(
        future: result,
        builder: (_, builder) {
          if (builder.connectionState == ConnectionState.waiting) {
            return loading();
          }
          if (builder.data.state == ApiState.ERROR ||
              builder.data.stations == null) {
            return error();
          }

          List<ListTile> result = (builder.data.stations as List<Station>)
              .map((station) => _listTile(station, context))
              .toList();

          return new Container(
            child: new SingleChildScrollView(
              child: Column(
                children: result,
              ),
            ),
          );
        });
  }

  ListTile _listTile(Station station, BuildContext context) {
    var genres = '';
    if (station.genres.isNotEmpty) {
      genres = ' - ' + station.genres.map((genre) => genre.title).join(', ');
    }
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.black))),
          child: Icon(Icons.favorite, color: Colors.black),
        ),
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
              var item = PlayerItem(
                  station.id.toString(), station.title, response[0].url);
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

  Column emptyQueryMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(
            "Search term must not be empty",
          ),
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }

  Widget loading() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new CircularProgressIndicator(),
        new Text(
          "  Loading...",
          textAlign: TextAlign.center,
        )
      ],
    ));
  }

  Widget error() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text(
          "Search failed... Please try again.",
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}
