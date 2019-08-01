import 'package:audio_service/audio_service.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/popular_stations/radio_stations_model.dart';

import '../station.dart';

class ModelsSynchroniser {
  String _stationId;

  final RadioPlayerModel _radioPlayerModel;

  final RadioStationsModel _popularStationsModel;

  ModelsSynchroniser(this._radioPlayerModel, this._popularStationsModel) {
    _refreshStateFromBackgroundService();
    this._popularStationsModel.addListener(_refreshAssignments);
  }

  void _refreshAssignments() {
    Station foundStation = this
        ._popularStationsModel
        .getStations()
        .firstWhere((station) => station.getId() == _stationId, orElse: () {
      return null;
    });
    if (foundStation != null) {
      _radioPlayerModel.setStation(foundStation);
    }
  }

  void _refreshStateFromBackgroundService() async {
    await AudioService.connect();
    if (!await AudioService.running) {
      return;
    }
    var currentMediaItemId = await AudioService.currentMediaItem?.id;
    if (currentMediaItemId != null) {
      _stationId = currentMediaItemId;
    }
    _refreshAssignments();
  }
}
