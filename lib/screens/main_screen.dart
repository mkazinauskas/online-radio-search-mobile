import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/screens/player/player_screen.dart';

import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black54,
          title: Text('Radio stations'),
//            actions: <Widget>[
//              IconButton(
//                  icon: Icon(Icons.search),
//                  onPressed: () {
//                    showSearch(context: context, delegate: DataSearch());
//                  })
//            ],
        ),
        body: PlayerScreen()
//          Column(
//            children: <Widget>[
//              Expanded(
//                child: RadioStationsWidget(),
//              ),
//              Consumer<RadioPlayerModel>(
//                builder: (context, model, child) {
//                  return model.hasStation()
//                      ? PlayerWidget()
//                      : new Container(width: 0, height: 0);
//                },
//              ),
//            ],
//          ),
        );
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
//                  PlayerController.stop();
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
