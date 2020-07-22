import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';

class StationsClient {
  static const _url =
      "https://api.onlineradiosearch.com/radio-stations?sort=id%2Cdesc&page=0&size=20&enabled=true";

  static const _search_url =
      "https://api.onlineradiosearch.com/search/radio-station?title={title}&page=0&size=20&enabled=true";

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

  Future<Result> search(String title) {
    var url = _search_url.replaceAll('{title}', title);
    return http
        .get(url)
        .then((responseBody) =>
            _SearchRadioStationsFromJsonParser.parseStations(responseBody.body))
        .then((stations) {
      return Result(stations, ApiState.COMPLETE);
    }).catchError((error) {
      return Result(List<Station>(), ApiState.ERROR);
    });
  }
}

class _LatestRadioStationsFromJsonParser {
  static List<Station> parseStations(String responseBody) {
    var embedded = JsonCodec().decode(responseBody)['_embedded'];
    if (embedded == null) {
      return List<Station>();
    }
    dynamic decoded = embedded['radioStationResponseList'];
    return List<Station>.from(decoded.map(_singleStation).toList());
  }

  static _singleStation(dynamic json) {
    return Station(
      (json['id'] as int),
      json['uniqueId'] as String,
      json['title'] as String,
      json['website'] as String,
      (json['genres'] as List<dynamic>)
          .map((genre) => Genre(genre['title']))
          .toList(),
    );
  }
}

class _SearchRadioStationsFromJsonParser {
  static List<Station> parseStations(String responseBody) {
    var embedded = JsonCodec().decode(responseBody)['_embedded'];
    if (embedded == null) {
      return List<Station>();
    }
    dynamic decoded = embedded['searchRadioStationResultResponseList'];
    return List<Station>.from(decoded.map(_singleStation).toList());
  }

  static _singleStation(dynamic json) {
    var genres = json['genres'] as List<dynamic>;
    return Station(
      (json['id'] as int),
      json['uniqueId'] as String,
      json['title'] as String,
      json['website'] as String,
      genres == null
          ? []
          : genres.map((genre) => Genre(genre['title'])).toList(),
    );
  }
}

class Result {
  final List<Station> stations;
  final ApiState state;

  Result(this.stations, this.state);
}

class Station {
  final int id;
  final String uniqueId;
  final String title;
  final String website;
  final List<Genre> genres;

  const Station(this.id, this.uniqueId, this.title, this.website, this.genres);
}

class Genre {
  final title;

  Genre(this.title);
}
