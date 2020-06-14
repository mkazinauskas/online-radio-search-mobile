import 'package:flutter_test/flutter_test.dart';
import 'package:onlineradiosearchmobile/station.dart';

void main() {
  test('Should serialize station data', () async {
    var station = Station('123', 'Super Station', 'http://coolUrl.com');

    var result = station.toJson();

    expect(result, isNotNull);

    var expectedJson =
        '{"_id":"123","_url":"http://coolUrl.com","_title":"Super Station"}';

    expect(result, equalsIgnoringHashCodes(expectedJson));
  });

  test('Should deserialize station data', () async {
    const json =
        '{"_id":"123","_url":"http://coolUrl.com","_title":"Super Station"}';

    var result = Station.fromJson(json);

    expect(
      result,
      isNotNull,
    );
    expect(
      result.getId(),
      equalsIgnoringHashCodes('123'),
    );

    expect(
      result.getTitle(),
      equalsIgnoringHashCodes('Super Station'),
    );

    expect(
      result.getUrl(),
      equalsIgnoringHashCodes('http://coolUrl.com'),
    );
  });
}
