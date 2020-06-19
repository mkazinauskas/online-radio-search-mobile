import 'package:audio_service/audio_service.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';
import 'package:onlineradiosearchmobile/screens/player/audio_player_task.dart';

class AudioServiceController {
  static void start() {
    AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Online Radio Search',
      // Enable this if you want the Android service to exit the foreground state on pause.
      //androidStopForegroundOnPause: true,
      androidNotificationColor: 0x3273dc,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
    );
  }

  static void changeStation(PlayerItem playerItem) {
    AudioService.customAction(
      AudioServiceActions.changeStation.toString(),
      playerItem.toJson(),
    );
  }
}

enum AudioServiceActions { changeStation }

// NOTE: Your entrypoint MUST be a top-level function.
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
