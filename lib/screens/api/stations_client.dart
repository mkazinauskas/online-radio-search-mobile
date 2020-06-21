import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';

class StationsClient {
  static const _url =
      "https://api.onlineradiosearch.com/radio-stations?sort=id%2Cdesc&page=0&size=20&enabled=true";

  final dynamic _onComplete;

  StationsClient(this._onComplete);

  void load() async {
    http
        .get(_url)
        .then((responseBody) =>
            _LatestRadioStationsFromJsonParser.parseStations(responseBody.body))
        .then((stations) {
          _onComplete(stations, ApiState.COMPLETE);
        })
        .catchError((error) => _onComplete(List<Station>(), ApiState.ERROR))
        .whenComplete(() {});
  }
}

class _LatestRadioStationsFromJsonParser {
  static List<Station> parseStations(String responseBody) {
    dynamic decoded = JsonCodec().decode(responseBody)['_embedded']
        ['radioStationResponseList'];
    return List<Station>.from(decoded.map(_singleStation).toList());
  }

  static _singleStation(dynamic json) {
    return Station(
        (json['id'] as int),
        json['title'] as String,
        json['website'] as String,
        (json['genres'] as List<dynamic>)
            .map((genre) => Genre(genre['title']))
            .toList(),
    );
  }
}

class Station {
  final int id;
  final String title;
  final String website;
  final List<Genre> genres;

  Station(this.id, this.title, this.website, this.genres);
}

class Genre {
  final title;

  Genre(this.title);
}
