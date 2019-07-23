import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../station.dart';

class RadioPlayerModel extends ChangeNotifier {
  
  Station _station;

  String _id = '';

  String _url = '';

  String _title = 'Please select radio station';

  RadioPlayerModel();

  void setFromStation(Station station){
    _station = station;
    _id = _station.getId();
    _url = station.getUrl();
    _title = station.getTitle();
    notifyListeners();
  }

  String getId(){
    return this._id;
  }

  String setId(String id) {
    this._id = id;
    notifyListeners();
  }

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
    _id = convert['_id'];
    _url = convert['_url'];
    _title = convert['_title'];
  }

  String toJson() {
    Map<String, String> data = {
      '_id': _id,
      '_url': _url,
      '_title': _title,
    };
    return new JsonEncoder().convert(data);
  }
}
