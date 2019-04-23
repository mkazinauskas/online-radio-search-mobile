import 'package:audioplayer/audioplayer.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_data_source.dart';

class AudioState {
  final AudioPlayer _audioPlayer = new AudioPlayer();
  Station _station;
  bool _isPlaying;

  void setStation(Station station){
    stop();
    _station = station;
    play();
  }

  void play(){
    _audioPlayer.play(_station.url, isLocal: true);
    _isPlaying = true;
  }

  void stop(){
    _audioPlayer.stop();
    _isPlaying = false;
  }

  String title(){
    return _station.title;
  }

  bool hasStation(){
    return _station != null;
  }

  bool isPlaying(){
    return _isPlaying;
  }
}
