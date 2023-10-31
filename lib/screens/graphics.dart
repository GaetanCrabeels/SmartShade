import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Graphics extends StatefulWidget {
  const Graphics({Key? key}) : super(key: key);

  @override
  _GraphicsState createState() => _GraphicsState();
}

class _GraphicsState extends State<Graphics> {
  String weatherDataText = 'Chargement des données météorologiques...';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiUrl = 'https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly/tsa,plu,hra/1,26/2018-09-01/2018-09-05/';
    final token = '253bb380830eb71192fdb2d3af85f23849fb7e7e';

    final url = Uri.parse(apiUrl);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      setState(() {
        weatherDataText = response.body;
      });
    } else {
      print('Erreur lors de la requête API : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo en Belgique'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            weatherDataText,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
