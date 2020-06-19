import 'dart:convert';

class PlayerItem {
  final String id;
  final String title;
  final String url;

  PlayerItem(this.id, this.title, this.url);

  static PlayerItem fromJson(String json) {
    var item = JsonCodec().decode(json);
    return new PlayerItem(item['_id'], item['_title'], item['_url']);
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
