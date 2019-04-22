import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/list.dart';
import 'package:onlineradiosearchmobile/popular_stations/popular_stations_widget.dart';

class MainWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        appBar: AppBar(
//          title: Text('Radio'),
//          actions: <Widget>[
//            IconButton(
//                icon: Icon(Icons.search),
//                onPressed: () {
//                  showSearch(context: context, delegate: DataSearch());
//                })
//          ],
//        ),
        body: PopularStationsWidget(),
        drawer: Drawer());
  }
}