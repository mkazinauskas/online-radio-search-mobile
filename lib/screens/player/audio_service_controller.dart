import 'package:audio_service/audio_service.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';
import 'package:onlineradiosearchmobile/screens/player/audio_player_task.dart';

class AudioServiceController {
  static Future<void> start(PlayerItem playerItem) async {
    if (AudioService.running) {
      return;
    }
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Online Radio Search',
      // Enable this if you want the Android service to exit the foreground state on pause.
      //androidStopForegroundOnPause: true,
      androidNotificationColor: 0x3273dc,
      androidNotificationIcon: 'mipmap/ic_launcher',
      params: {'radioStation': playerItem.toJson()},
      androidEnableQueue: true,
    );
  }

  static Future<void> stop() async {
    if (AudioService.running) {
      if (!AudioService.connected) {
        await AudioService.connect();
      }
      await AudioService.stop();
    }
  }

  static Future<void> changeStation(PlayerItem playerItem) async {
    if (theSameStationIsPlaying(playerItem)) {
      return;
    }

    if (AudioService.running) {
      await stop();
      await start(playerItem);
    } else {
      await start(playerItem);
    }
  }

  static bool theSameStationIsPlaying(PlayerItem playerItem) {
    var currentMediaItem = AudioService.currentMediaItem;
    return currentMediaItem != null &&
        AudioService.playbackState.playing &&
        currentMediaItem.id == playerItem.streamUrl;
  }
}

enum AudioServiceActions { changeStation }

// NOTE: Your entrypoint MUST be a top-level function.
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
