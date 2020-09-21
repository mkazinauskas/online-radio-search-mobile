import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/screens/search/commands/queries_repository.dart';

class QueriesList {
  static Widget createTile(
      Query query, BuildContext context, dynamic tapAction) {
    return Card(
      elevation: 10.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.blue),
        child: ListTile(
          leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                    border: new Border(
                      right: new BorderSide(width: 1.0, color: Colors.white24),
                    ),
                  ),
                  child: Icon(Icons.history, color: Colors.white),
                )
              ]),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            query.query,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
          onTap: tapAction,
        ),
      ),
    );
  }
}
