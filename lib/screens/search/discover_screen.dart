import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main.dart';
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/app_bottom_navigation_bar.dart';
import 'package:onlineradiosearchmobile/screens/search/stations_list_creator.dart';

import 'custom_search_delegate.dart';

class DiscoverScreen extends StatefulWidget {
  DiscoverScreen({Key key}) : super(key: key);

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<Station> _radioStations = [];
  ApiState _state = ApiState.LOADING;

  _DiscoverScreenState() {
    StationsClient((List<Station> stations, ApiState state) => {
          this.setState(() {
            _state = state;

            _radioStations.clear();
            if (stations.isNotEmpty) {
              _radioStations.addAll(stations);
            }
          })
        }).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              })
        ],
      ),
      body: renderBody(),
      bottomNavigationBar:
          AppBottomNavigationBar(context, SearchNavigationBarItem()),
    );
  }

  Widget renderBody() {
    if (_state == ApiState.LOADING) {
      return Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
        ],
      ));
    }

    if (_state == ApiState.ERROR) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            color: Colors.white,
            iconSize: 54,
            icon: Icon(Icons.refresh_sharp),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, Routes.SEARCH),
          ),
        ],
      ));
    }

    final dynamic backAction = () {
      setState(() {});
    };

    var stationsList = _radioStations
        .map((station) =>
            StationsListCreator.createTile(station, context, backAction))
        .toList();

    return new Container(
        child: new SingleChildScrollView(
            child: Column(
      children: stationsList,
    )));
  }
}
