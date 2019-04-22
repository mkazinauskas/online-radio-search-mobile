import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LatestStations {
  final _url =
      'https://modestukasai.github.io/onlineradiosearch_data/popular-stations.json';

  Future<List<Station>> read() async {
    final response = await http.get(_url);

    return compute(parseStations, response.body);
  }

  List<Station> parseStations(String responseBody) {
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
