import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
          Navigator.pushNamedAndRemoveUntil(
              _buildContext, Routes.SEARCH, (route) => false);
        }
        break;
      case FavouritesNavigationBarItem.index_value:
        {
          Navigator.pushNamedAndRemoveUntil(
              _buildContext, Routes.FAVOURITES, (route) => false);
        }
        break;
      case PlayerNavigationBarItem.index_value:
        {
          if (AudioService.running) {
            Navigator.pushNamedAndRemoveUntil(
                _buildContext, Routes.PLAYER, (route) => false);
          } else {
            Fluttertoast.showToast(
              msg: 'Please select station to play.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          }
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
