import 'package:flutter/foundation.dart';
import 'package:optional/optional_internal.dart';

import '../station.dart';

class RadioPlayerModel extends ChangeNotifier {
  Station _station;

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
}
