import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/search/stations_list_creator.dart';

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

  Widget emptyQueryMessage() {
    return Column(
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  Widget loading() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new CircularProgressIndicator(),
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
