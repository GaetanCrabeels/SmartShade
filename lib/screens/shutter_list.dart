import 'package:flutter/material.dart';

class Shutter {
  final String name;
  bool isOn;

  Shutter({required this.name, this.isOn = false});
}

class Room {
  final String name;
  bool isOn;
  List<Shutter> shutters;

  Room({required this.name, this.isOn = false, required this.shutters});
}

class ShutterList extends StatefulWidget {
  const ShutterList({Key? key}) : super(key: key);

  @override
  _ShutterListState createState() => _ShutterListState();
}

class _ShutterListState extends State<ShutterList> {
  List<Shutter> shutters = [
    Shutter(name: 'Volet 1'),
    Shutter(name: 'Volet 2'),
    Shutter(name: 'Volet 3'),
    Shutter(name: 'Volet 4'),
    //liste de volets a add manuellement pr test
  ];

  List<Room> rooms = [
    Room(name: 'Salon', shutters: []),
    Room(name: 'Chambre', shutters: []),
    Room(name: 'Cuisine', shutters: []),
    // liste de piece a add manuellement pr test
  ];

  bool showShutters = true; // Toggle pour l'affichage de la liste des volets
  bool showRooms = false; // toggle pour l'affichage de la liste des pieces

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Volets'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {   // Etat qui définit qu'elle liste est affichée
                showShutters = true;
                showRooms = false;
              });
            },
            icon: const Icon(Icons.list),
            tooltip: 'Liste des Volets',
          ),
          IconButton(
            onPressed: () { // Etat qui définit qu'elle liste est affichée
              setState(() {
                showShutters = false;
                showRooms = true;
              });
            },
            icon: const Icon(Icons.apartment),
            tooltip: 'Liste des Pièces',
          ),
        ],
      ),
      body: showShutters ? _buildShutters() : _buildRooms(),
      floatingActionButton: showShutters ? _addShutterButton() : _addRoomButton(), // bouton qui en focntion de  liste affichée montre le bon
    );
  }

  //bouton add volet
  Widget _addShutterButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddShutterDialog(context);
      },
      child: const Icon(Icons.add),
    );
  }

  //bouton add piece
  Widget _addRoomButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddRoomDialog(context);
      },
      child: const Icon(Icons.add),
    );
  }

  // liste de volets
  Widget _buildShutters() {
    return ListView(
      children: shutters.map((shutter) {
        final roomContainingShutter = rooms.firstWhere((room) => room.shutters.contains(shutter), orElse: () => Room(name: 'Aucune pièce', shutters: []));
        final roomName = roomContainingShutter.name != 'Aucune pièce' ? '(${roomContainingShutter.name})' : '';
        
        return ListTile(
          title: Row(
            children: [
              Text(shutter.name),
              const SizedBox(width: 8),
              Text(
                roomName,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Switch(
            value: shutter.isOn,
            onChanged: (value) {
              setState(() {
                shutter.isOn = value;
                _updateShutterInRooms(shutter);
              });
            },
          ),
          onTap: () {
            _moveShutter(shutter);
          },
        );
      }).toList(),
    );
  }

  // ajouter volet
  void _addShutter(String name) {
    setState(() {
      shutters.add(Shutter(name: name));
    });
  }

  // deplacer volet dans une piece
  void _moveShutter(Shutter shutter) {
    Room? selectedRoom;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Déplacer le Volet'),
              content: DropdownButton<Room>(
                hint: const Text('Sélectionner une Pièce'),
                value: selectedRoom,
                items: rooms.map((Room room) {
                  return DropdownMenuItem<Room>(
                    value: room,
                    child: Text(room.name),
                  );
                }).toList(),
                onChanged: (Room? room) {
                  setState(() {
                    selectedRoom = room;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedRoom != null) {
                      setState(() {
                        _moveShutterToRoom(shutter, selectedRoom!);
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // deplacer volet dans piece
  void _moveShutterToRoom(Shutter shutter, Room room) {
    final currentRoom = rooms.firstWhere((room) => room.shutters.contains(shutter), orElse: () => Room(name: '', shutters: []));

    setState(() {
      currentRoom.shutters.remove(shutter);
      room.shutters.add(shutter);
      shutter.isOn = room.isOn;
      _updateShutterInRooms(shutter);
    });
  }

  // utile pour ajouter le volet dans la piece
  void _updateShutterInRooms(Shutter shutter) {
    rooms.forEach((room) {
      final index = room.shutters.indexWhere((s) => s.name == shutter.name);
      if (index != -1) {
        room.shutters[index].isOn = shutter.isOn;
      }
    });
  }

  // constronction liste piece
  Widget _buildRooms() {
    return ListView(
      children: rooms.map((room) {
        return ExpansionTile(
          title: Row(
            children: [
              Text(room.name),
              Spacer(),
              Switch(
                value: room.isOn,
                onChanged: (value) {
                  setState(() {
                    room.isOn = value;
                    _updateRoomShutters(room);
                  });
                },
              ),
            ],
          ),
          children: _buildRoomShutters(room),
        );
      }).toList(),
    );
  }

  List<Widget> _buildRoomShutters(Room room) {
    return room.shutters.map((shutter) {
      return ListTile(
        title: Text(shutter.name),
        trailing: ElevatedButton(
          onPressed: () {
            setState(() {
              room.shutters.remove(shutter);
              shutters.firstWhere((s) => s.name == shutter.name).isOn = false;
            });
          },
          child: const Text('Retirer'),
        ),
      );
    }).toList();
  }


  // check les volets dans les pieces
  void _updateRoomShutters(Room room) {
    room.shutters.forEach((shutter) {
      shutters.firstWhere((s) => s.name == shutter.name).isOn = room.isOn;
    });
  }

  // textuel pour le nouveau volet
  void _showAddShutterDialog(BuildContext context) {
    String newShutterName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nouveau Volet'),
          content: TextField(
            onChanged: (value) {
              newShutterName = value;
            },
            decoration: const InputDecoration(hintText: 'Nom du Volet'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newShutterName.isNotEmpty) {
                  _addShutter(newShutterName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  //texutel pour le nouvelle piece
  void _showAddRoomDialog(BuildContext context) {
    String newRoomName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nouvelle Pièce'),
          content: TextField(
            onChanged: (value) {
              newRoomName = value;
            },
            decoration: const InputDecoration(hintText: 'Nom de la Pièce'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newRoomName.isNotEmpty) {
                  _addRoom(newRoomName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  // ajout de la new peice
  void _addRoom(String name) {
    setState(() {
      rooms.add(Room(name: name, shutters: []));
    });
  }
}
