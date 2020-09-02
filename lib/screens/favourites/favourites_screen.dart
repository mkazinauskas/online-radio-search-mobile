import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/app_bottom_navigation_bar.dart';
import 'package:onlineradiosearchmobile/screens/favourites/commands/favourites_repository.dart';
import 'package:onlineradiosearchmobile/screens/search/stations_list_creator.dart';

class FavouritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<List<FavouriteStation>> allFavourites =
        FavouritesRepository.findAll();
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourites'),
      ),
      body: FutureBuilder(
          future: allFavourites,
          builder: (_, builder) {
            if (builder.connectionState != ConnectionState.done) {
              return loading();
            }

            if (builder.error != null) {
              return error();
            }

            if (builder.data.isEmpty) {
              return noResults();
            }

            List<Widget> result = (builder.data as List<FavouriteStation>)
                .map(
                  (e) => Station(
                    int.parse(e.radioStationId),
                    e.uniqueId,
                    e.title,
                    '',
                    e.genres.map((e) => Genre(e)).toList(),
                  ),
                )
                .map((station) =>
                    StationsListCreator.createTile(station, context, () {

                    }))
                .toList();

            return new Container(
              child: new SingleChildScrollView(
                child: Column(
                  children: result,
                ),
              ),
            );
          }),
      bottomNavigationBar:
          AppBottomNavigationBar(context, FavouritesNavigationBarItem()),
    );
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
          "Failed to load favourite stations.",
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }

  Widget noResults() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text(
          "No results, please add Radio Stations",
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}
