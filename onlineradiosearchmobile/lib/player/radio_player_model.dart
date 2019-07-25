import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:optional/optional_internal.dart';

import '../station.dart';

class RadioPlayerModel extends ChangeNotifier {
  Station _station;

  RadioPlayerModel();

  void setStation(Station station) {
    _station = station;
    notifyListeners();
  }

  Optional<Station> getStation() {
    return Optional.ofNullable(_station);
  }

  String getDuration() {
    return '';
  }

  bool hasStation() {
    return getStation().isPresent;
  }

  RadioPlayerModel.fromData(String dataAsJson) {
    var convert = JsonCodec().decode(dataAsJson);
    var station = convert['_station'];
    this._station =
        new Station(station['_id'], station['_title'], station['_url']);
  }

  String toJson() {
    Map<String, Map<String, String>> data = {
      '_station': _station != null
          ? {
              '_id': _station.id,
              '_url': _station.url,
              '_title': _station.title,
            }
          : null,
    };
    return new JsonEncoder().convert(data);
  }
}
