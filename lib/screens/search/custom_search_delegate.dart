import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/api/streams_client.dart';
import 'package:onlineradiosearchmobile/screens/player/audio_service_controller.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';
import 'package:onlineradiosearchmobile/screens/search/stations_list_creator.dart';

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
              .map(
                  (station) => StationsListCreator.createTile(station, context))
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
