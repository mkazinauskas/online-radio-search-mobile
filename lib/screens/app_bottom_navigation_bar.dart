import 'package:flutter/material.dart';
import 'package:onlineradiosearchmobile/main.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final BuildContext _buildContext;
  final NavigationBarItem _navigationBarItem;

  AppBottomNavigationBar(this._buildContext, this._navigationBarItem);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          title: Text('Search'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          title: Text('Favourites'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_arrow),
          title: Text('Player'),
        ),
      ],
      currentIndex: _navigationBarItem.index,
//      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    if (index == _navigationBarItem.index) {
      return;
    }
    switch (index) {
      case SearchNavigationBarItem.index_value:
        {
          Navigator.pushReplacementNamed(_buildContext, Routes.SEARCH);
        }
        break;
      case FavouritesNavigationBarItem.index_value:
        {
          Navigator.pushReplacementNamed(_buildContext, Routes.FAVOURITES);
        }
        break;
      case PlayerNavigationBarItem.index_value:
        {
          Navigator.pushReplacementNamed(_buildContext, Routes.PLAYER);
        }
        break;
      default:
        {
          throw Exception("No bar index found");
        }
        break;
    }
  }
}

class NavigationBarItem {
  final int index;

  NavigationBarItem(this.index);
}

class SearchNavigationBarItem extends NavigationBarItem {
  static const int index_value = 0;

  SearchNavigationBarItem() : super(index_value);
}

class FavouritesNavigationBarItem extends NavigationBarItem {
  static const int index_value = 1;

  FavouritesNavigationBarItem() : super(index_value);
}

class PlayerNavigationBarItem extends NavigationBarItem {
  static const int index_value = 2;

  PlayerNavigationBarItem() : super(index_value);
}
