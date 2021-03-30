import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onlineradiosearchmobile/ads/ad_unit.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/app_bottom_navigation_bar.dart';
import 'package:onlineradiosearchmobile/screens/favourites/commands/favourites_repository.dart';
import 'package:onlineradiosearchmobile/screens/search/stations_list_creator.dart';

import '../../ads/banner_ad_widget.dart';

class FavouritesScreen extends StatefulWidget {
  FavouritesScreen({Key key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<FavouritesScreen> {
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
                      setState(() {});
                    }))
                .toList();

            return new Container(
              child: new SingleChildScrollView(
                child: Column(
                  children: [
                    adTop(result.length),
                    ...result,
                    adBottom(result.length)
                  ],
                ),
              ),
            );
          }),
      bottomNavigationBar:
          AppBottomNavigationBar(context, FavouritesNavigationBarItem()),
    );
  }

  Widget adTop(int lengthOfItems) {
    if (lengthOfItems == 0) {
      return SizedBox.shrink();
    }
    return Card(
      margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: BannerAdWidget(
        AdSize.fullBanner,
        AdUnit.favouritesBannerTop,
      ),
    );
  }

  Widget adBottom(int lengthOfItems) {
    if (lengthOfItems == 0) {
      return SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 15.0),
      child: BannerAdWidget(
        AdSize.mediumRectangle,
        AdUnit.favouritesBannerBottom,
      ),
    );
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
          'Failed to load favourite stations.',
          style: TextStyle(color: Colors.white),
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
          'No results, please add Radio Stations',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}
