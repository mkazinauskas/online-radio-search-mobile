import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';

class StreamsClient {
  static const _url =
      "https://api.onlineradiosearch.com/radio-stations/{radioStationId}/streams";

  final dynamic _onComplete;

  StreamsClient(this._onComplete);

  void load(int radioStationId) async {
    var url = _url.replaceAll('{radioStationId}', radioStationId.toString());
    http
        .get(url)
        .then((responseBody) => _ResponseJsonToObjectConverter.convert(
            utf8.decode(responseBody.bodyBytes)))
        .then((data) {
          _onComplete(data, ApiState.COMPLETE);
        })
        .catchError((error) => _onComplete([], ApiState.ERROR))
        .whenComplete(() {});
  }
}

class StreamResponse {
  final int id;
  final String url;
  final bool working;

  StreamResponse(this.id, this.url, this.working);
}

class _ResponseJsonToObjectConverter {
  static List<StreamResponse> convert(String responseBody) {
    dynamic decoded = JsonCodec().decode(responseBody)['_embedded']
        ['radioStationStreamResponseList'];
    return List<StreamResponse>.from(decoded.map(_singleStation).toList());
  }

  static _singleStation(dynamic json) {
    return StreamResponse(
      (json['id'] as int),
      json['url'] as String,
      json['working'] as bool,
    );
  }
}
