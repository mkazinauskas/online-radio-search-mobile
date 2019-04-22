import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PopularStationsDataSource {
  final String _url =
      'https://modestukasai.github.io/onlineradiosearch_data/popular-stations.json';

  void read(onPopularStationsDownloaded) {
    http
        .get(_url)
        .then((responseBody) => _parseStations(responseBody.body))
        .then((stations) => onPopularStationsDownloaded(stations))
        .catchError((error) => {debugPrint("Error" + error)})
        .whenComplete(() {
      debugPrint("Done");
    });
  }

  List<Station> _parseStations(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Station>((json) => Station.fromJson(json)).toList();
  }
}

class Station {
  final int id;
  final String title;
  final String url;

  Station({this.id, this.title, this.url});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
        id: json['id'] as int,
        title: json['title'] as String,
        url: json['url'] as String);
  }
}
