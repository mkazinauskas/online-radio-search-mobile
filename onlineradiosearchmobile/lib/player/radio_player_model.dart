import 'dart:convert';

import 'package:flutter/foundation.dart';

class RadioPlayerModel extends ChangeNotifier {
  String _url = '';

  String _title = 'Please select radio station';

  RadioPlayerModel();

  String getUrl() {
    return this._url;
  }

  String setUrl(String url) {
    this._url = url;
    notifyListeners();
  }

  String getTitle() {
    return this._title;
  }

  String setTitle(String streamName) {
    this._title = streamName;
    notifyListeners();
  }

  String getDuration() {
    return '';
  }

  RadioPlayerModel.fromData(String dataAsJson) {
    var convert = JsonCodec().decode(dataAsJson);
    _url = convert['_url'];
    _title = convert['_title'];
  }

  String toJson() {
    Map<String, String> data = {
      '_url': _url,
      '_title': _title,
    };
    return new JsonEncoder().convert(data);
  }
}
