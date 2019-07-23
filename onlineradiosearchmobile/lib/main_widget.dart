import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/player_widget.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_widget.dart';

class MainWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainWidgetState();
  }
}

class MainWidgetState extends State<MainWidget> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black54,
            title: Text('Popular stations'),
//            actions: <Widget>[
//              IconButton(
//                  icon: Icon(Icons.search),
//                  onPressed: () {
//                    showSearch(context: context, delegate: DataSearch());
//                  })
//            ],
          ),
          body: Column(
              children: <Widget>[
            Expanded(
              child: PopularStationsWidget(),
            ),
            PlayerWidget()
          ].where((widget) => widget != null).toList()),
//          bottomNavigationBar: BottomNavigationBar(
//              currentIndex: 0,
//              fixedColor: Colors.deepPurple,
//              items: <BottomNavigationBarItem>[
//                BottomNavigationBarItem(
//                  title: Text('Main'),
//                  icon: Icon(Icons.home),
//                ),
//                BottomNavigationBarItem(
//                  title: Text('Search'),
//                  icon: Icon(Icons.search),
//                ),
//                BottomNavigationBarItem(
//                  title: Text('Favourites'),
//                  icon: Icon(Icons.favorite),
//                )
//              ]),
//            drawer: Drawer()
        ));
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () {
                  AudioService.stop();
                  Navigator.of(context).pop(true);
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
