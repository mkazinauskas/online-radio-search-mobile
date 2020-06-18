import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class StationsReader {
  final _url = "https://api.onlineradiosearch.com";

  Future<List<String>> read() async {
    var request = await HttpClient().getUrl(Uri.parse(_url));

    var response = await request.close();

    List<String> items = [];
    await for (var contents in response.transform(Utf8Decoder())) {
      contents.split(":").forEach(debugPrint);
      items.addAll(contents.split(":").toList());
      debugPrint(contents);
    }

    return Future(() => items);
  }
}
