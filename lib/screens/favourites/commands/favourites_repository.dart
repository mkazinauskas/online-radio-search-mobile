import 'dart:async';

import 'package:optional/optional_internal.dart';
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
      String _path = await getDatabasesPath() + 'favourites';
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
        .then((value) => value.map(FavouriteStation._fromMap).toList());
  }

  static Future<Optional<FavouriteStation>> findOne(
          String radioStationId) async =>
      await init()
          .then((value) => _db.query(_table_name,
              where: 'radioStationId = ?', whereArgs: [radioStationId]))
          .then((value) => value.length > 0 ? value.first : null)
          .then(FavouriteStation._fromMap)
          .then((value) => Optional.ofNullable(value));

  static Future<int> insert(FavouriteStation model) async {
    return init().then((value) => _db.insert(_table_name, model.toMap()));
  }

  static Future<void> delete(int id) async => await init().then(
      (value) => _db.delete(_table_name, where: 'id = ?', whereArgs: [id]));
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
      'genres': genres.isEmpty ? "" : genres.join(";")
    };
    return map;
  }

  static FavouriteStation _fromMap(Map<String, dynamic> input) {
    if (input == null) {
      return null;
    }
    var genres = (input['genres'] as String);
    return FavouriteStation(
      id: input['id'] as int,
      radioStationId: input['radioStationId'].toString(),
      uniqueId: input['uniqueId'],
      title: input['title'],
      streamUrl: input['streamUrl'],
      genres: genres.isEmpty ? [] : genres.split(';'),
    );
  }
}
