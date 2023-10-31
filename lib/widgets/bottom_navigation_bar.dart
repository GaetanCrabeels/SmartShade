import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/shutter_list.dart';
import '../screens/parameters.dart';
import '../screens/graphics.dart';


class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    //Liste des pages
    const HomePage(),
    const ShutterList(),
    const Text('Index 2: Utilisateur'),
    const Parameters(),
    const Graphics(),
  ];

//Selection de la page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _widgetOptions[0] = const HomePage();
      } else if (_selectedIndex == 1) {
        _widgetOptions[1] = const ShutterList();
      } else if (_selectedIndex == 2) {
        _widgetOptions[2] = const Text('Index 2: Utilisateur');
      } else if (_selectedIndex == 3) {
        _widgetOptions[3] = const Parameters();
      } else if (_selectedIndex == 4) {
        _widgetOptions[4] = const Graphics();
    }});
  }

//Barre de navigation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Volets',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Utilisateur',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Parametres',
            backgroundColor: Colors.pink,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: 'Graphique',
            backgroundColor: Colors.red,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
