import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onlineradiosearchmobile/ads/banner_ad_widget.dart';
import 'package:onlineradiosearchmobile/screens/api/api_state.dart';
import 'package:onlineradiosearchmobile/screens/api/stations_client.dart';
import 'package:onlineradiosearchmobile/screens/search/commands/queries_repository.dart';
import 'package:onlineradiosearchmobile/screens/search/queriesList.dart';
import 'package:onlineradiosearchmobile/screens/search/stations_list_creator.dart';
import 'package:uuid/uuid.dart';

class CustomSearchDelegate extends SearchDelegate {
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        hintStyle: TextStyle(color: Colors.white70),
      ),
      textTheme: theme.textTheme.copyWith(
        headline6: theme.textTheme.headline6.copyWith(color: Colors.white),
        overline: theme.textTheme.headline6.copyWith(color: Colors.white),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 1) {
      return noSearchResults();
    }

    var result = StationsClient(() {}).search(query);

    return FutureBuilder(
        future: result,
        builder: (_, builder) {
          if (builder.connectionState == ConnectionState.waiting) {
            return loading();
          }
          if (builder.data.state == ApiState.ERROR ||
              builder.data.stations == null) {
            return error();
          }

          List<Widget> result = (builder.data.stations as List<Station>)
              .map((station) =>
                  StationsListCreator.createTile(station, context, () {}))
              .toList();

          if (result.isEmpty) {
            return noSearchResults();
          }

          QueriesRepository.insert(Query(uniqueId: Uuid().v4(), query: query));

          return Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  adTop(result.length),
                  ...result,
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 1) {
      return _buildSuggestions(QueriesRepository.findAll(20), context);
    }

    return _buildSuggestions(
        QueriesRepository.findAllByQuery(query, 20), context);
  }

  Widget _buildSuggestions(Future<List<Query>> future, BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (_, builder) {
        if (builder.connectionState == ConnectionState.waiting) {
          return loading();
        }

        if (builder.data == null) {
          return emptySuggestions();
        }

        List<Widget> result = (builder.data as List<Query>)
            .map(
              (singleQuery) => QueriesList.createTile(
                singleQuery,
                context,
                () {
                  query = singleQuery.query;
                  showResults(context);
                },
              ),
            )
            .toList();

        if (result.isEmpty) {
          return emptySuggestions();
        }

        return Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                adTop(result.length),
                ...result,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget adTop(int lengthOfItems) {
    if (lengthOfItems == 0) {
      return SizedBox.shrink();
    }
    return Card(
      margin: EdgeInsets.only(bottom: 5.0),
      child: BannerAdWidget(AdSize.fullBanner),
    );
  }

  Widget loading() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
      ],
    ));
  }

  Widget emptySuggestions() {
    return message('No history, try to click search button');
  }

  Widget noSearchResults() {
    return message('Nothing found. Please refine your search');
  }

  Widget error() {
    return message('Search failed... Please try again');
  }

  Widget message(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
