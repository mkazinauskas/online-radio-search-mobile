import 'package:onlineradiosearchmobile/screens/favourites/commands/favourites_repository.dart';

class AddToFavouritesCommand {
  final String radioStationId;
  final String uniqueId;
  final String title;
  final String streamUrl;
  final List<String> genres;

  AddToFavouritesCommand(
      this.radioStationId, this.uniqueId, this.title, this.streamUrl, this.genres);
}

class AddToFavouritesHandler {
  void handler(AddToFavouritesCommand command) {
    _Validator.validate(command);
    FavouriteStation station = FavouriteStation(
        radioStationId: command.radioStationId,
        uniqueId: command.uniqueId,
        title: command.title,
        streamUrl: command.streamUrl,
        genres: command.genres);
    FavouritesRepository.insert(station);
  }
}

class _Validator {
  static void validate(AddToFavouritesCommand command) {
    if (command.radioStationId == null) {
      throw Exception("Radio station id cannot be null");
    }
    //Todo: finish
  }
}
