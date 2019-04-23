import 'package:audioplayer/audioplayer.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_data_source.dart';

class AudioState {
  Station _station;
  final AudioPlayer _audioPlayer = new AudioPlayer();

  void setStation(Station station){
    stop();
    _station = station;
    play();
  }

  void play(){
    _audioPlayer.play(_station.url, isLocal: true);
  }

  void stop(){
    _audioPlayer.stop();
  }

  String title(){
    return _station.title;
  }

  bool hasStation(){
    return _station != null;
  }
}
