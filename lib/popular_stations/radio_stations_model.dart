import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:optional/optional.dart';

import '../station.dart';

class RadioStationsModel extends ChangeNotifier {
  final List<Station> _stations = [];

  PopularStationsLoadingState _loadingState = PopularStationsLoadingState.NONE;

  RadioStationsModel() {
    loadDataFromLocalSystem();
//    downloadData();
  }

  void retryDataLoading() async {
    loadDataFromLocalSystem();
//    downloadData();
  }

  void downloadData() async {
    PopularStationsDataSource().read(_addStations, _setLoadingState);
  }

  void loadDataFromLocalSystem() async {
    new StationsLocalDataSource().load().then(_addStations).whenComplete(() {
      _loadingState = PopularStationsLoadingState.COMPLETE;
    }).catchError((error) {
      _loadingState = PopularStationsLoadingState.ERROR;
    });
  }

  void _setLoadingState(PopularStationsLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _addStations(List<Station> stations) {
    if (stations == null) {
      return;
    }
    _stations.addAll(stations);
    notifyListeners();
  }

  List<Station> getStations() {
    return List.unmodifiable(_stations);
  }

  Optional<Station> findById(String id) {
    return Optional.ofNullable(_stations
        .firstWhere((station) => station.getId() == id, orElse: () => null));
  }

  int stationsCount() {
    return _stations.length;
  }

  PopularStationsLoadingState loadingState() {
    return _loadingState;
  }
}

class StationsLocalDataSource {
  final PATH = 'assets/data/stations.json';

  Future<List<Station>> load() async {
    String data = await rootBundle.loadString(PATH);
    return StationsFromJsonParser.parseStations(data);
  }
}

class PopularStationsDataSource {
  final String _url =
      'https://modestukasai.github.io/onlineradiosearch_data/popular-stations.json';

  void read(onComplete, onStateChange) async {
    onStateChange(PopularStationsLoadingState.NONE);
    http
        .get(_url)
        .then((responseBody) =>
            StationsFromJsonParser.parseStations(responseBody.body))
        .then((stations) {
          onComplete(stations);
          onStateChange(PopularStationsLoadingState.COMPLETE);
        })
        .catchError((error) => onStateChange(PopularStationsLoadingState.ERROR))
        .whenComplete(() {});
  }
}

class StationsFromJsonParser {
  static List<Station> parseStations(String responseBody) {
    return List<Station>.from(
        JsonCodec().decode(responseBody).map(_singleStation).toList());
  }

  static _singleStation(dynamic json) {
    return Station(
      (json['id'] as int).toString(),
      json['title'] as String,
      json['url'] as String,
    );
  }
}

enum PopularStationsLoadingState { NONE, COMPLETE, ERROR }
