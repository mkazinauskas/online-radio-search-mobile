import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/player/player_widget.dart';
import 'package:onlineradiosearchmobile/player/radio_player.dart';
import 'package:onlineradiosearchmobile/player/radio_player_model.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_widget.dart';
import 'package:provider/provider.dart';

class MainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () => _onWillPop(context),
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
              Consumer<RadioPlayerModel>(
                builder: (context, model, child) {
                  return model.hasStation()
                      ? PlayerWidget()
                      : new Container(width: 0, height: 0);
                },
              ),
            ],
          ),
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

  Future<bool> _onWillPop(BuildContext context) {
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
                  PlayerController.stop();
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
