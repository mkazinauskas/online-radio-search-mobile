import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onlineradiosearchmobile/main.dart';
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';
import 'package:onlineradiosearchmobile/screens/api/streams_client.dart';
import 'package:onlineradiosearchmobile/screens/app_bottom_navigation_bar.dart';
import 'package:onlineradiosearchmobile/screens/player/audio_service_controller.dart';
import 'package:onlineradiosearchmobile/screens/player/player_item.dart';
import 'package:onlineradiosearchmobile/screens/search/latest_radio_station.dart';
import 'package:onlineradiosearchmobile/screens/search/latest_radio_stations.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<LatestRadioStation> _radioStations = [];
  PopularStationsLoadingState _state = PopularStationsLoadingState.LOADING;

  _SearchScreenState() {
    LatestRadioStations((List<LatestRadioStation> stations,
            PopularStationsLoadingState state) =>
        {
          this.setState(() {
            _state = state;
            _radioStations.clear();
            _radioStations.addAll(stations);
          })
        }).load();
  }

  @override
  Widget build(BuildContext context) {
    var text = _state != PopularStationsLoadingState.COMPLETE
        ? [Text(_state.toString())]
        : [];

    List<ListTile> list = [];
    if (_state == PopularStationsLoadingState.COMPLETE) {
      list = _radioStations
          .map((station) =>
              _listTile(station.id, station.title, station.website))
          .toList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
//            actions: <Widget>[
//              IconButton(
//                  icon: Icon(Icons.search),
//                  onPressed: () {
//                    showSearch(context: context, delegate: DataSearch());
//                  })
//            ],
      ),
      body: new Container(
          child: new SingleChildScrollView(
              child: Column(
        children: <Widget>[...text, ...list],
      ))),
      bottomNavigationBar:
          AppBottomNavigationBar(context, SearchNavigationBarItem()),
    );
  }

  ListTile _listTile(int id, String title, String website) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.black))),
          child: Icon(Icons.favorite, color: Colors.black),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
            Icon(Icons.linear_scale, color: Colors.black),
            Flexible(
              child: Text(
                website == null ? "" : website,
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onTap: () {
          StreamsClient((List<StreamResponse> response, ApiState state) {
            if (state == ApiState.COMPLETE) {
              response.retainWhere((element) => element.working);
              if (response.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'No working stream found.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                );
                return;
              }
              var item = PlayerItem(id.toString(), title, response[0].url);
              AudioServiceController.changeStation(item);
              Navigator.pushReplacementNamed(context, Routes.PLAYER);
            } else {
              Fluttertoast.showToast(
                msg: 'Failed to load data.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            }
          }).load(id);
        },
        trailing:
            Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0));
  }
}
