import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Shutter {
  final String id;
  final String name;
  String room;
  bool isOn;

  Shutter({required this.id,required this.name, this.room = "indépendant", this.isOn = false});
}

class Room {
  final String id;
  final String name;
  bool isOn;
  List<Shutter> shutters;

  Room({required this.id,required this.name, this.isOn = false, required this.shutters});
}

class ShutterList extends StatefulWidget {
  const ShutterList({Key? key}) : super(key: key);

  @override
  _ShutterListState createState() => _ShutterListState();
}

class _ShutterListState extends State<ShutterList> {

  // MISE EN PLACE DE LA LISTE DES VOLETS et Pieces
  List<Shutter> shutters = [];
  List<Room> rooms = [];
  List<Shutter> shutterInRooms = [];

  CollectionReference shutterCollection = FirebaseFirestore.instance.collection('shutters');
  CollectionReference roomCollection = FirebaseFirestore.instance.collection('rooms');

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
        // Création d'un objet Shutter en utilisant les champs du document Firestore
        return Shutter(
          id: doc.id,
          name: data['shutter_name'] as String,
          room: data['room_id'] as String,
          isOn: data['shutter_open'] as bool? ?? false,
        );
      } else {
        // Gérer le cas où les données sont nulles ou absentes
        return Shutter(id : 'id inconnu',name: 'Nom inconnu', room: 'inconnu');
      }
    }).toList();

    setState(() {
      shutters = fetchedShutters;
    });
    _fetchRoomsFromFirestore();
  }

  Future<void> _fetchRoomsFromFirestore() async {
    
    QuerySnapshot<Object?> snapshot = await roomCollection.get();

    List<Room> fetchedRooms = snapshot.docs.map((doc) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        String roomName = data['room_name'] as String;
  
        print("ok  $roomName");
        List<Shutter> roomShutters = shutters
            .where((shutter) => roomName == shutter.room)
            .toList();
        print(roomShutters);
        return Room(
          id: doc.id,
          name: data['room_name'] as String,
          isOn: data['shutters_open'] as bool? ?? false,
          shutters: roomShutters,
        );
      } else {
        return Room(id : 'inconnu',name: 'Nom inconnu', shutters: []);
      }
    }).toList();

    setState(() {
      rooms = fetchedRooms;
    });
  }



  bool showShutters = true; // Toggle pour l'affichage de la liste des volets
  bool showRooms = false; // toggle pour l'affichage de la liste des pieces

///////
///////
///
///OK
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

  //bouton add volet OKK
  Widget _addShutterButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddShutterDialog(context);
      },
      child: const Icon(Icons.add),
    );
  }

  //bouton add piece Okkk
  Widget _addRoomButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddRoomDialog(context);
      },
      child: const Icon(Icons.add),
    );
  }

  // liste de volets // Normalement OK
  Widget _buildShutters() {
  return ListView(
    children: shutters.map((shutter) {
      final roomContainingShutter = rooms.firstWhere(
        (room) => room.shutters.contains(shutter),
        orElse: () => Room(id:'id',name: shutter.room, shutters: []),
      );
      String roomName = '(${roomContainingShutter.name})'; // Toujours entre parenthèses

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

//update de la database sur l'etat du volet
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




  // ajouter volet

  
  void _addShutter(String name) {
    final newShutter = Shutter(id: 'generated_id', name: name);
    
    setState(() {
      shutters.add(newShutter);
    });

    // Ajouter le nouveau volet à Firestore
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


  //TEST
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

  // deplacer volet dans piece
  void _moveShutterToRoom(Shutter shutter, Room room) {
    final currentRoom = rooms.firstWhere((room) => room.shutters.contains(shutter), orElse: () => Room(id:"inconnu",name: '', shutters: []));

    setState(() {
      currentRoom.shutters.remove(shutter);
      room.shutters.add(shutter);
      shutter.isOn = room.isOn;
      shutter.room = room.name;
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
                    _updateRoomOpenInDatabase(room);
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
              _updateShutterDeleteRoomInDatabase(shutter);
            });
          },
          child: const Text('Retirer'),
        ),
      );
    }).toList();
  }

void _updateShutterDeleteRoomInDatabase(Shutter shutter) {
 
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
  // Récupérer la référence au document Firestore correspondant à la pièce
  DocumentReference documentReference = FirebaseFirestore.instance.collection('rooms').doc(room.id);


  documentReference.update({
    'shutters_open': room.isOn,  
  }).then((value) {
    print('Room updated successfully!');
  }).catchError((error) {
    print('Failed to update room: $error');
  });
}

  // check les volets dans les pieces
  void _updateRoomShutters(Room room) {
    room.shutters.forEach((shutter) {
      shutters.firstWhere((s) => s.name == shutter.name).isOn = room.isOn;
      _updateShutterOpenInDatabase(shutter);
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

}