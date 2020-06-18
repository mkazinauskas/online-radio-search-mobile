import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main.dart';
import 'package:onlineradiosearchmobile/screens/app_bottom_navigation_bar.dart';
import 'package:onlineradiosearchmobile/screens/player/player_screen.dart';

import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('Discover'),
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
            child: IconButton(
              icon: Icon(Icons.skip_next),
              onPressed: () => {Navigator.pushNamed(context, Routes.PLAYER)},
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          AppBottomNavigationBar(context, SearchNavigationBarItem()),
    );
  }
}
