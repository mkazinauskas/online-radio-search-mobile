import 'dart:convert';

class PlayerItem {
  final String id;
  final String uniqueId;
  final String title;
  final String streamUrl;
  final List<String> genres;

  const PlayerItem(
      this.id, this.uniqueId, this.title, this.streamUrl, this.genres);

  static PlayerItem fromJson(String json) {
    var item = JsonCodec().decode(json);
    return new PlayerItem(
      item['_id'],
      item['_uniqueId'],
      item['_title'],
      item['_streamUrl'],
      (item['_genres'] as String).split(';'),
    );
  }

  String toJson() {
    Map<String, String> data = {
      '_id': id,
      '_uniqueId': uniqueId,
      '_title': title,
      '_streamUrl': streamUrl,
      '_genres': genres.join(';')
    };
    return new JsonEncoder().convert(data);
  }
}
