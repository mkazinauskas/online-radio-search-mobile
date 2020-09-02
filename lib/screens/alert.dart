import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alert {
  static void show(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(title),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
