import 'package:flutter/material.dart';

class RandomWordsState extends State<RandomWords> {
  var _suggestions = <String>["asd", "asd", "asdasd"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                })
          ],
        ),
        body: items(),
        drawer: Drawer());
  }

  Widget items() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          debugPrint("Index: ${i}");
          if (i < _suggestions.length) {
            return _buildRow(_suggestions[i]);
          } else {
            return null;
          }
        });
  }

  Widget _buildRow(String pair) {
    return ListTile(
      onTap: () {
        debugPrint("Index: ${pair}");
        setState(() {
          _suggestions = ["abc"];
        });
      },
      title: Text(pair.toLowerCase(), style: TextStyle(fontSize: 18.0)),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final cities = ["shit", "penis", "go", "shitty"];

  final recentCities = ["shit", "penis"];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
        height: 100.0,
        width: 100.0,
        child: Card(
            color: Colors.red,
            child: Center(
              child: Text(query),
            )));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentCities
        : cities
            .where((item) => item.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
            onTap: () {
              showResults(context);
            },
            leading: Icon(Icons.location_city),
            title: RichText(
                text: TextSpan(
                    text: suggestionList[index].substring(0, query.length),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                  TextSpan(
                      text: suggestionList[index].substring(query.length),
                      style: TextStyle(color: Colors.grey))
                ]))),
        itemCount: suggestionList.length);
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}
