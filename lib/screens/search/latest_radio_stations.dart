import 'dart:convert';

import 'package:http/http.dart' as http;

import 'latest_radio_station.dart';

class LatestRadioStations {
  static const _url =
      "https://api.onlineradiosearch.com/radio-stations?sort=id%2Cdesc&page=0&size=20";

  final dynamic _onComplete;

  LatestRadioStations(this._onComplete);

  void load() async {
    http
        .get(_url)
        .then((responseBody) =>
            _LatestRadioStationsFromJsonParser.parseStations(responseBody.body))
        .then((stations) {
          _onComplete(stations, PopularStationsLoadingState.COMPLETE);
        })
        .catchError(
            (error) => _onComplete([], PopularStationsLoadingState.ERROR))
        .whenComplete(() {});
  }
}

class _LatestRadioStationsFromJsonParser {
  static List<LatestRadioStation> parseStations(String responseBody) {
    dynamic decoded = JsonCodec().decode(responseBody)['_embedded']
        ['radioStationResponseList'];
    return List<LatestRadioStation>.from(decoded.map(_singleStation).toList());
  }

  static _singleStation(dynamic json) {
    return LatestRadioStation(
      (json['id'] as int),
      json['title'] as String,
      json['website'] as String,
    );
  }
}

enum PopularStationsLoadingState { LOADING, COMPLETE, ERROR }
