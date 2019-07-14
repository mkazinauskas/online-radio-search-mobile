import 'package:flutter/foundation.dart';

class RadioPlayerModel extends ChangeNotifier {
  String _url = '';

  String _title = 'Test';

  String getUrl() {
    return this._url;
  }

  String setUrl(String url) {
    this._url = url;
    notifyListeners();
  }

  String getTitle() {
    return this._title;
  }

  String setTitle(String streamName) {
    this._title = streamName;
    notifyListeners();
  }

  String getDuration() {
    return '';
  }
}
