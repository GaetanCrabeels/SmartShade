import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Shutter {
  final String id;
  final String name;
  String room;
  bool isOn;

  Shutter({
    required this.id,
    required this.name,
    this.room = "indépendant",
    this.isOn = false,
  });
}

class Room {
  final String id;
  final String name;
  bool isOn;
  List<Shutter> shutters;

  Room({
    required this.id,
    required this.name,
    this.isOn = false,
    required this.shutters,
  });
}

class ShutterList extends StatefulWidget {
  const ShutterList({Key? key, required String houseId}) : super(key: key);

  @override
  _ShutterListState createState() => _ShutterListState();
}

class _ShutterListState extends State<ShutterList> {
  List<Shutter> shutters = [];
  List<Room> rooms = [];

  CollectionReference shutterCollection =
      FirebaseFirestore.instance.collection('shutters');
  CollectionReference roomCollection =
      FirebaseFirestore.instance.collection('rooms');

  @override
  void initState() {
    super.initState();
    _fetchShuttersAndRoomsFromFirestore();
  }

  Future<void> _fetchShuttersAndRoomsFromFirestore() async {
    QuerySnapshot<Object?> snapshot = await shutterCollection.get();

    List<Shutter> fetchedShutters = snapshot.docs.map((doc) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        return Shutter(
          id: doc.id,
          name: data['shutter_name'] as String,
          room: data['room_id'] as String,
          isOn: data['shutter_open'] as bool? ?? false,
        );
      } else {
        return Shutter(id: 'id inconnu', name: 'Nom inconnu', room: 'inconnu');
      }
    }).toList();

    QuerySnapshot<Object?> roomSnapshot = await roomCollection.get();

    List<Room> fetchedRooms = roomSnapshot.docs.map((doc) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        String roomName = data['room_name'] as String;

        List<Shutter> roomShutters = fetchedShutters
            .where((shutter) => roomName == shutter.room)
            .toList();

        return Room(
          id: doc.id,
          name: data['room_name'] as String,
          isOn: data['shutters_open'] as bool? ?? false,
          shutters: roomShutters,
        );
      } else {
        return Room(id: 'inconnu', name: 'Nom inconnu', shutters: []);
      }
    }).toList();

    setState(() {
      shutters = fetchedShutters;
      rooms = fetchedRooms;
    });
  }

  bool showShutters = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Volets'),
        actions: [
          IconButton(
            onPressed: () {
              _fetchShuttersAndRoomsFromFirestore();
            },
            icon: const Icon(Icons.list),
            tooltip: 'Liste des Volets',
          ),
        ],
      ),
      body: _buildShuttersOrRooms(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShuttersOrRooms() {
    return ListView(
      children: showShutters ? [_buildShutters()] : [_buildRooms()],
    );
  }

  Widget _addShutterButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddShutterDialog(context);
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _addRoomButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddRoomDialog(context);
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _buildShutters() {
    return shutters.isEmpty
        ? Center(child: Text('Aucun volet trouvé'))
        : Column(
            children: shutters.map((shutter) {
              final roomContainingShutter = rooms.firstWhere(
                (room) => room.shutters.contains(shutter),
                orElse: () => Room(id: 'id', name: shutter.room, shutters: []),
              );
              String roomName =
                  '(${roomContainingShutter.name})'; // Toujours entre parenthèses

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
                    _updateShutterInRooms(shutter, value);
                  },
                ),
                onTap: () {
                  _moveShutter(shutter);
                },
              );
            }).toList(),
          );
  }

  void _updateShutterOpenInDatabase(Shutter shutter) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('shutters').doc(shutter.id);

    documentReference.update({
      'shutter_open': shutter.isOn,
    }).then((value) {
      print('Shutter updated successfully!');
    }).catchError((error) {
      print('Failed to update shutter: $error');
    });
  }

  void _updateShutterRoomInDatabase(Shutter shutter) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('shutters').doc(shutter.id);

    documentReference.update({
      'room_id': shutter.room,
    }).then((value) {
      print('Shutter updated successfully!');
    }).catchError((error) {
      print('Failed to update shutter: $error');
    });
  }

  void _addShutter(String name) {
    final newShutter = Shutter(id: 'generated_id', name: name);

    setState(() {
      shutters.add(newShutter);
    });

    shutterCollection.add({
      'shutter_name': newShutter.name,
      'shutter_open': newShutter.isOn,
      'room_id': newShutter.room,
      'shutter_mov': false,
    }).then((value) {
      print('Shutter added to Firestore successfully!');
    }).catchError((error) {
      print('Failed to add shutter to Firestore: $error');
    });
  }

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
                        _updateShutterRoomInDatabase(shutter);
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

  void _moveShutterToRoom(Shutter shutter, Room room) {
    final currentRoom = rooms.firstWhere(
        (room) => room.shutters.contains(shutter),
        orElse: () => Room(id: "inconnu", name: '', shutters: []));

    setState(() {
      currentRoom.shutters.remove(shutter);
      room.shutters.add(shutter);
      shutter.isOn = room.isOn;
      shutter.room = room.name;
      _updateShutterInRooms(shutter);
    });
  }

  void _updateShutterInRooms(Shutter shutter, [bool? value]) {
    rooms.forEach((room) {
      final index = room.shutters.indexWhere((s) => s.name == shutter.name);
      if (index != -1) {
        if (value != null) {
          room.shutters[index].isOn = value;
        } else {
          room.shutters[index].isOn = shutter.isOn;
        }
      }
    });

    _updateShutterOpenInDatabase(shutter);
    _updateRoomShutters(shutter as Room);
  }

  Widget _buildRooms() {
    return rooms.isEmpty
        ? Center(child: Text('Aucune pièce trouvée'))
        : Column(
            children: rooms.map((room) {
              return ExpansionTile(
                title: Row(
                  children: [
                    Text(room.name),
                    Spacer(),
                    Switch(
                      value: room.isOn,
                      onChanged: (value) {
                        _updateRoomOpenInDatabase(room, value);
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
            _removeShutterFromRoom(shutter, room);
          },
          child: const Text('Retirer'),
        ),
      );
    }).toList();
  }

  void _updateShutterDeleteRoomInDatabase(Shutter shutter) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('shutters').doc(shutter.id);

    documentReference.update({
      'room_id': "indépendant",
    }).then((value) {
      print('Room reference deleted successfully for the shutter!');
    }).catchError((error) {
      print('Failed to delete room reference for the shutter: $error');
    });
  }

  void _updateRoomOpenInDatabase(Room room, [bool? value]) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('rooms').doc(room.id);

    if (value != null) {
      room.isOn = value;
    }

    documentReference.update({
      'shutters_open': room.isOn,
    }).then((value) {
      print('Room updated successfully!');
    }).catchError((error) {
      print('Failed to update room: $error');
    });

    _updateRoomShutters(room);
  }

  void _updateRoomShutters(Room room) {
    room.shutters.forEach((shutter) {
      shutters.firstWhere((s) => s.name == shutter.name).isOn = room.isOn;
      _updateShutterOpenInDatabase(shutter);
    });
  }

  void _removeShutterFromRoom(Shutter shutter, Room room) {
    setState(() {
      room.shutters.remove(shutter);
      _updateShutterDeleteRoomInDatabase(shutter);
      _updateShutterInRooms(shutter);
    });
  }

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
    final newRoom = Room(id: name, name: name, shutters: []);

    setState(() {
      rooms.add(newRoom);
    });

    // Ajouter la nouvelle pièce à Firestore
    roomCollection.add({
      'room_name': newRoom.name,
      'shutters_open': newRoom.isOn,
    }).then((value) {
      print('Room added to Firestore successfully!');
    }).catchError((error) {
      print('Failed to add room to Firestore: $error');
    });
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nouveau Volet'),
          content: TextField(
            onChanged: (value) {
              // handle the input
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
                // handle the addition of the shutter
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
