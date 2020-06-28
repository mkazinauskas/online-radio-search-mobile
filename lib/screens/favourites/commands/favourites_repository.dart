import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavouritesRepository {
  static final _table_name = 'favourite_radio_stations';
  static Database _db;

  static int get _version => 1;

  static Future<void> init() async {
    if (_db != null) {
      return;
    }

    try {
      String _path = await getDatabasesPath() + 'example';
      _db = await openDatabase(_path, version: _version, onCreate: _onCreate);
    } catch (ex) {
      print(ex);
    }
  }

  static void _onCreate(Database db, int version) async {
    if (version == 1) {
      await db.execute(
          'CREATE TABLE favourite_radio_stations (id INTEGER PRIMARY KEY NOT NULL, radioStationId STRING UNIQUE NOT NULL, uniqueId STRING NOT NULL, title STRING NOT NULL, streamUrl STRING NOT NULL, genres STRING)');
    }
  }

  static Future<List<FavouriteStation>> findAll() async {
    return init()
        .then((value) => _db.query(_table_name))
        .then((value) => value.map(FavouriteStation.fromMap).toList());
  }

  static Future<int> insert(FavouriteStation model) async {
    return init().then((value) => _db.insert(_table_name, model.toMap()));
  }

  static Future<int> update(FavouriteStation model) async =>
      await _db.update(_table_name, model.toMap(),
          where: 'id = ?', whereArgs: [model.id]);

  static Future<int> delete(FavouriteStation model) async =>
      await _db.delete(_table_name, where: 'id = ?', whereArgs: [model.id]);
}

class FavouriteStation {
  final int id;
  final String radioStationId;
  final String uniqueId;
  final String title;
  final String streamUrl;
  final List<String> genres;

  const FavouriteStation(
      {this.id,
      this.radioStationId,
      this.uniqueId,
      this.title,
      this.streamUrl,
      this.genres});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'radioStationId': radioStationId,
      'uniqueId': uniqueId,
      'title': title,
      'streamUrl': streamUrl,
      'genres': genres == null ? "" : genres.join(";")
    };
    return map;
  }

  static FavouriteStation fromMap(Map<String, dynamic> input) {
    return FavouriteStation(
        id: input['id'] as int,
        radioStationId: input['radioStationId'].toString(),
        uniqueId: input['uniqueId'],
        title: input['title'],
        streamUrl: input['streamUrl'],
        genres: (input['genres'] as String).split(';'));
  }
}
