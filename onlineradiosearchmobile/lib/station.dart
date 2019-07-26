import 'dart:convert';

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

  static Station fromJson(String json) {
    var station = JsonCodec().decode(json);
    return new Station(station['_id'], station['_title'], station['_url']);
  }

  String toJson() {
    Map<String, String> data = {
        '_id': id,
        '_url': url,
        '_title': title,
    };
    return new JsonEncoder().convert(data);
  }
}