import 'package:flutter_test/flutter_test.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/station.dart';

void main() {
  test('Model should serialize station data', () async {
    var station = Station('123', 'Super Station', 'http://coolUrl.com');

    var model = new RadioPlayerModel();
    model.setStation(station);

    var result = model.toJson();

    expect(result, isNotNull);

    expect(
        result,
        equalsIgnoringHashCodes(
            '{"_station":{"_id":"123","_url":"http://coolUrl.com","_title":"Super Station"}}'));
  });

  test('Model should serialize station data when no station', () async {
    var model = new RadioPlayerModel();

    var result = model.toJson();

    expect(result, isNotNull);

    expect(result, equalsIgnoringHashCodes('{"_station":null}'));
  });

  test('Model should deserialize station data', () async {
    const modelAsJson =
        '{"_station":{"_id":"123","_url":"http://coolUrl.com","_title":"Super Station"}}';

    var result = new RadioPlayerModel.fromData(modelAsJson);

    expect(
      result.getStation(),
      isNotNull,
    );
    expect(
      result.getStation().value.getId(),
      equalsIgnoringHashCodes('123'),
    );

    expect(
      result.getStation().value.getTitle(),
      equalsIgnoringHashCodes('Super Station'),
    );

    expect(
      result.getStation().value.getUrl(),
      equalsIgnoringHashCodes('http://coolUrl.com'),
    );
  });
}
