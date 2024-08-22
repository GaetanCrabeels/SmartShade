import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Shutter {
  final String id;
  String name;
  String room;
  bool isOn;

  Shutter({required this.id, required this.name, this.room = "indépendant", this.isOn = false});
}

class Room {
  final String id;
  final String name;
  bool isOn;
  List<Shutter> shutters;
  String mode; // Ajout du champ mode

  Room({required this.id, required this.name, this.isOn = false, required this.shutters, this.mode = 'manuelle'});
}

class ShutterList extends StatefulWidget {
  const ShutterList({Key? key}) : super(key: key);

  @override
  _ShutterListState createState() => _ShutterListState();
}

class _ShutterListState extends State<ShutterList> {
  String? _houseId;
  String? _userId;
  List<Shutter> shutters = [];
  List<Room> rooms = [];
  List<Shutter> shutterInRooms = [];

  CollectionReference shutterCollection = FirebaseFirestore.instance.collection('shutters');
  CollectionReference roomCollection = FirebaseFirestore.instance.collection('rooms');

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
    _fetchRoomsFromFirestore();
    _fetchHouseId();
  }

  Future<void> _fetchHouseId() async {
    try {
      if (_userId != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        if (userDoc.exists) {
          String? houseId = userDoc.get('houseId');

          setState(() {
            _houseId = houseId;
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'identifiant de la maison : $e');
    }
  }

  Future<void> _fetchRoomsFromFirestore() async {
    try {
      if (_userId != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        if (userDoc.exists) {
          String? houseId = userDoc.get('houseId');

          if (houseId != null) {
            QuerySnapshot<Object?> roomSnapshot = await FirebaseFirestore.instance
                .collection('rooms')
                .where('houseId', isEqualTo: houseId)
                .get();

            List<Room> fetchedRooms = roomSnapshot.docs.map((doc) {
              Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

              if (data != null) {
                return Room(
                  id: doc.id,
                  name: data['room_name'] as String,
                  isOn: data['shutters_open'] as bool? ?? false,
                  mode: data['mode'] as String? ?? 'manuelle', // Récupération du mode depuis Firestore
                  shutters: [],
                );
              } else {
                return Room(id: 'inconnu', name: 'Nom inconnu', shutters: [], mode: 'manuelle');
              }
            }).toList();

            setState(() {
              rooms = fetchedRooms;
            });

            _fetchShuttersFromFirestore();
            _fetchShuttersForRooms();
          } else {
            print('ID de la maison non trouvé pour cet utilisateur.');
          }
        } else {
          print('Le document de l\'utilisateur n\'existe pas.');
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des pièces : $e');
    }
  }

  Future<void> _fetchShuttersForRooms() async {
    try {
      for (Room room in rooms) {
        QuerySnapshot<Object?> shutterSnapshot = await FirebaseFirestore.instance
            .collection('shutters')
            .where('room_id', isEqualTo: room.id)
            .get();

        List<Shutter> roomShutters = shutterSnapshot.docs.map((doc) {
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

        setState(() {
          room.shutters = roomShutters;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des volets pour les pièces : $e');
    }
  }

  Future<void> _fetchShuttersFromFirestore() async {
    try {
      if (_userId != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        if (userDoc.exists) {
          String? houseId = userDoc.get('houseId');

          if (houseId != null) {
            QuerySnapshot<Object?> roomSnapshot = await FirebaseFirestore.instance
                .collection('shutters')
                .where('houseId', isEqualTo: houseId)
                .get();

            List<Shutter> fetchedShutters = roomSnapshot.docs.map((doc) {
              Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

              if (data != null) {
                return Shutter(
                  id: doc.id,
                  name: data['shutter_name'] as String,
                  room: data['room_id'] as String,
                  isOn: data['shutter_open'] as bool? ?? false,
                );
              } else {
                return Shutter(
                  id: 'id inconnu',
                  name: 'Nom inconnu',
                  room: 'inconnu',
                  isOn: false,
                );
              }
            }).toList();

            setState(() {
              shutters = fetchedShutters;
              for (Shutter shutter in shutters) {
                for (Room room in rooms) {
                  if (shutter.room == room.id) {
                    shutter.room = room.name;
                  }
                }
              }
            });
          } else {
            print('ID de la maison non trouvé pour cet utilisateur.');
          }
        } else {
          print('Le document de l\'utilisateur n\'existe pas.');
        }
      } else {
        print('L\'ID de l\'utilisateur est nul.');
      }
    } catch (e) {
      print('Erreur lors de la récupération des volets : $e');
    }
  }

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
              setState(() {
                showShutters = true;
                showRooms = false;
              });
            },
            icon: const Icon(Icons.list),
            tooltip: 'Liste des Volets',
          ),
          IconButton(
            onPressed: () {
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
      floatingActionButton: showShutters ? null : _addRoomButton(),
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
    return ListView(
      children: shutters.map((shutter) {
        final roomContainingShutter = rooms.firstWhere(
          (room) => room.shutters.contains(shutter),
          orElse: () => Room(id: 'id', name: shutter.room, shutters: []),
        );
        String roomName = '(${roomContainingShutter.name})'; // Toujours entre parenthèses

        return ListTile(
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showRenameDialog(context, shutter);
                },
              ),
              Expanded(  // Ajout de Expanded ici pour éviter le débordement
                child: Text(shutter.name),
              ),
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
                _updateShutterOpenInDatabase(shutter);
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

  void _showRenameDialog(BuildContext context, Shutter shutter) {
    final TextEditingController controller = TextEditingController(text: shutter.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Renommer le volet'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Nom du volet"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _renameShutter(shutter, controller.text);
                Navigator.of(context).pop();
              },
              child: Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _renameShutter(Shutter shutter, String newName) {
    setState(() {
      shutter.name = newName;
    });

    DocumentReference documentReference = FirebaseFirestore.instance.collection('shutters').doc(shutter.id);

    documentReference.update({
      'shutter_name': newName,
    }).then((value) {
      print('Shutter renamed successfully!');
    }).catchError((error) {
      print('Failed to rename shutter: $error');
    });
  }

  void _updateShutterOpenInDatabase(Shutter shutter) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('shutters').doc(shutter.id);

    documentReference.update({
      'shutter_open': shutter.isOn,
    }).then((value) {
      print('Shutter updated successfully!');
    }).catchError((error) {
      print('Failed to update shutter: $error');
    });
  }

  void _updateShutterRoomInDatabase(Shutter shutter) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('shutters').doc(shutter.id);

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
    final currentRoom = rooms.firstWhere((room) => room.shutters.contains(shutter), orElse: () => Room(id:"inconnu",name: '', shutters: []));

    setState(() {
      currentRoom.shutters.remove(shutter);
      room.shutters.add(shutter);
      shutter.isOn = room.isOn;
      shutter.room = room.id;
      _updateShutterInRooms(shutter);
    });
  }

  void _updateShutterInRooms(Shutter shutter) {
    rooms.forEach((room) {
      final index = room.shutters.indexWhere((s) => s.name == shutter.name);
      if (index != -1) {
        room.shutters[index].isOn = shutter.isOn;
      }
    });
  }

  Widget _buildRooms() {
    return ListView(
      children: rooms.map((room) {
        return ExpansionTile(
          title: Row(
            children: [
              Expanded(
                child: Text(room.name),
              ),
              IconButton(
                icon: Icon(Icons.settings), // Ajout de l'icône d'engrenage
                onPressed: () {
                  _showSettingsDialog(context, room);
                },
              ),
              Switch(
                value: room.isOn,
                onChanged: (value) {
                  setState(() {
                    room.isOn = value;
                    _updateRoomShutters(room);
                    _updateRoomOpenInDatabase(room);
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                onPressed: () {
                  _deleteRoom(room);
                },
              ),
            ],
          ),
          children: _buildRoomShutters(room),
        );
      }).toList(),
    );
  }

  void _deleteRoom(Room room) {
    setState(() {
      for (Shutter shutter in room.shutters) {
        shutter.room = 'indépendant';
        shutter.isOn = false;
        _updateShutterOpenInDatabase(shutter);
        _updateShutterRoomInDatabase(shutter);
      }
      rooms.remove(room);
      _deleteRoomFromDatabase(room);
    });
  }

  void _deleteRoomFromDatabase(Room room) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('rooms').doc(room.id);

    documentReference.delete().then((value) {
      print('Room deleted successfully!');
    }).catchError((error) {
      print('Failed to delete room: $error');
    });
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
              _updateShutterDeleteRoomInDatabase(shutter);
            });
          },
          child: const Text('Retirer'),
        ),
      );
    }).toList();
  }

  void _updateShutterDeleteRoomInDatabase(Shutter shutter) {
    shutter.room = "indépendant";
    DocumentReference documentReference = FirebaseFirestore.instance.collection('shutters').doc(shutter.id);

    documentReference.update({
      'room_id': "indépendant",
    }).then((value) {
      print('Room reference deleted successfully for the shutter!');
    }).catchError((error) {
      print('Failed to delete room reference for the shutter: $error');
    });
  }

  void _updateRoomOpenInDatabase(Room room) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('rooms').doc(room.id);

    documentReference.update({
      'shutters_open': room.isOn,
    }).then((value) {
      print('Room updated successfully!');
    }).catchError((error) {
      print('Failed to update room: $error');
    });
  }

  void _updateRoomShutters(Room room) {
    room.shutters.forEach((shutter) {
      shutters.firstWhere((s) => s.name == shutter.name).isOn = room.isOn;
      _updateShutterOpenInDatabase(shutter);
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

  void _addRoom(String name) {
    final newRoom = Room(id: '', name: name, shutters: []);

    setState(() {
      rooms.add(newRoom);
    });

    roomCollection.add({
      'room_name': newRoom.name,
      'shutters_open': newRoom.isOn,
      'houseId': _houseId,
    }).then((DocumentReference docRef) {
      setState(() {
        final updatedRoom = Room(id: docRef.id, name: name, shutters: []);
        rooms[rooms.indexOf(newRoom)] = updatedRoom;
      });
      print('Room added to Firestore successfully with ID: ${docRef.id}');
    }).catchError((error) {
      print('Failed to add room to Firestore: $error');
    });
  }

  void _showSettingsDialog(BuildContext context, Room room) {
    String? selectedMode = room.mode; // Utiliser le mode actuel depuis Firestore

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Text('Paramètres de ${room.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('Manuelle'),
                    value: 'manuelle',
                    groupValue: selectedMode,
                    onChanged: (String? value) {
                      setState(() {
                        selectedMode = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Luminosité'),
                    value: 'luminosité',
                    groupValue: selectedMode,
                    onChanged: (String? value) {
                      setState(() {
                        selectedMode = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Température'),
                    value: 'température',
                    groupValue: selectedMode,
                    onChanged: (String? value) {
                      setState(() {
                        selectedMode = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveRoomSettings(room, selectedMode);
                    Navigator.of(context).pop();
                  },
                  child: Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveRoomSettings(Room room, String? mode) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('rooms').doc(room.id);

    documentReference.update({
      'mode': mode, 
    }).then((value) {
      print('Room settings updated successfully!');
    }).catchError((error) {
      print('Failed to update room settings: $error');
    });
  }
}
