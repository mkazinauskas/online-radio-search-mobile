import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:optional/optional.dart';

import '../station.dart';

class PopularStationsModel extends ChangeNotifier {
  final List<Station> _stations = [];

  PopularStationsModel() {
    PopularStationsDataSource().read(_addStations);
  }

  void _addStation(Station station) {
    _stations.add(station);
    notifyListeners();
  }

  void _addStations(List<Station> stations) {
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
}

class PopularStationsDataSource {
  final String _url =
      'https://modestukasai.github.io/onlineradiosearch_data/popular-stations.json';

  void read(onComplete) async {
    http
        .get(_url)
        .then((responseBody) => _parseStations(responseBody.body))
        .then((stations) => onComplete(stations))
        .whenComplete(() {});
  }

  List<Station> _parseStations(String responseBody) {
    return List<Station>.from(
        JsonCodec().decode(responseBody).map(_singleStation).toList());
  }

  _singleStation(dynamic json) {
    return Station(
      (json['id'] as int).toString(),
      json['title'] as String,
      json['url'] as String,
    );
  }
}
