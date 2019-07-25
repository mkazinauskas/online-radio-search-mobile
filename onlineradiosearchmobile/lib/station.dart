class Station {

  final String id;

  final String title;

  final String url;

  Station(this.id, this.title, this.url);

  String getId() {
    return this.id;
  }

  String getUrl() {
    return this.url;
  }

  String getTitle() {
    return this.title;
  }

  bool equals(Station station){
    return id == station.getId();
  }
}