import 'dart:async';

import 'package:onlineradiosearchmobile/db/app_database.dart';

class QueriesRepository {
  static Future<List<Query>> findAllByQuery(String query, int limit) async {
    return AppDatabase.init()
        .then(
          (db) => db.query(
            Tables.queries,
            limit: limit,
            orderBy: 'id desc',
            where: "query like '%$query%'",
          ),
        )
        .then((value) => value.map(Query._fromMap).toList());
  }

  static Future<List<Query>> findAll(int limit) async {
    return AppDatabase.init()
        .then((db) => db.query(
              Tables.queries,
              limit: limit,
              orderBy: 'id desc',
            ))
        .then((value) => value.map(Query._fromMap).toList());
  }

  static Future<int> insert(Query model) async {
    return AppDatabase.init().then((db) {
      db.delete(Tables.queries, where: 'query = ?', whereArgs: [model.query]);
      return db;
    }).then((db) => db.insert(Tables.queries, model.toMap()));
  }
}

class Query {
  final int id;
  final String uniqueId;
  final String query;

  const Query({this.id, this.uniqueId, this.query});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'uniqueId': uniqueId,
      'query': query,
    };
    return map;
  }

  static Query _fromMap(Map<String, dynamic> input) {
    if (input == null) {
      return null;
    }
    return Query(
      id: input['id'] as int,
      uniqueId: input['uniqueId'],
      query: input['query'],
    );
  }

}
