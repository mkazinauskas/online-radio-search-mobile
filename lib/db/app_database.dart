import 'dart:async';
import 'dart:developer';

import 'package:sqflite/sqflite.dart';

const String databaseName = 'ors';

class AppDatabase {
  static Database _db;

  static int get _version => 2;

  static Future<Database> init() async {
    if (_db != null) {
      return Future.value(_db);
    }

    try {
      String _path = await getDatabasesPath() + '/' + databaseName;
      _db = await openDatabase(_path, version: _version, onCreate: _onCreate);
      return Future.value(_db);
    } catch (ex) {
      log('Failed to initiate database', error: ex);
      print(ex);
      return Future.error(_db);
    }
  }

  static void _onCreate(Database db, int version) async {
    if (version == 2) {
      await db.execute(
          'CREATE TABLE ${Tables.favouriteRadioStations} (id INTEGER PRIMARY KEY NOT NULL, radioStationId STRING UNIQUE NOT NULL, uniqueId STRING NOT NULL, title STRING NOT NULL, streamUrl STRING NOT NULL, genres STRING)');
      await db.execute(
          'CREATE TABLE ${Tables.queries} (id INTEGER PRIMARY KEY NOT NULL, uniqueId STRING NOT NULL, query TEXT NOT NULL)');
    }
  }
}

class Tables {
  static final String favouriteRadioStations = 'favourite_radio_stations';
  static final String queries = 'queries';
}
