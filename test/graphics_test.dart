import 'dart:typed_data';

import 'package:flutter_application_1/screens/graphics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';

class FakeClient implements http.Client {
  final http.Response fakeResponse;

  FakeClient(this.fakeResponse);

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return Future.value(fakeResponse);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Implémentation de base pour send
    return Future.value(http.StreamedResponse(
        Stream.fromIterable([fakeResponse.bodyBytes]),
        fakeResponse.statusCode));
  }

  @override
  void close() {
    // Pas d'implémentation nécessaire pour les tests
  }

  // Implémentez les méthodes suivantes de manière similaire, si nécessaire

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    // TODO: implement readBytes
    throw UnimplementedError();
  }
}

final apiUrl = Uri.parse('https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly_prev/tsa,plu,hra,ens,vvt/all/1/');
class MockClient extends Mock implements http.Client {}
void main() {
  group('Graphics Widget Tests', () {
    testWidgets('Graphics should render correctly', (WidgetTester tester) async {
      final weatherData = WeatherData(mtime: '10:00', tsa: 25.0, hra: 50.0, plu: 0.0, vvt: 5.0);
      final mockClient = MockClient();

      await tester.pumpWidget(MaterialApp(home: Graphics(weatherData: weatherData, client: mockClient)));
      expect(find.byType(Graphics), findsOneWidget);
    });
  });
  group('WeatherData Tests', () {
    test('WeatherData should hold correct values', () {
      final weatherData = WeatherData(mtime: '10:00', tsa: 25.0, hra: 50.0, plu: 0.0, vvt: 5.0);

      expect(weatherData.mtime, '10:00');
      expect(weatherData.tsa, 25.0);
      expect(weatherData.hra, 50.0);
      expect(weatherData.plu, 0.0);
      expect(weatherData.vvt, 5.0);
    });
  });
  group('Graphics API Tests', () {
    testWidgets('Graphics should display weather information', (WidgetTester tester) async {
      // Simuler une réponse de l'API contenant des données spécifiques
      final fakeResponse = http.Response(jsonEncode({
        "results": [
          {
            "mtime": "10:00",
            "tsa": "25.0",
            "hra": "50.0",
            "plu": "0.0",
            "vvt": "5.0"
          },
        ]
      }), 200);

      final fakeClient = FakeClient(fakeResponse);
      final weatherData = WeatherData(mtime: '10:00', tsa: 25.0, hra: 50.0, plu: 0.0, vvt: 5.0);

      await tester.pumpWidget(MaterialApp(home: Graphics(weatherData: weatherData, client: fakeClient)));

      // Trouver et appuyer sur le bouton pour charger les données
      final buttonFinder = find.byType(ElevatedButton);
      expect(find.byType(ElevatedButton), findsOne);

      await tester.tap(buttonFinder,warnIfMissed:true);

      expect(find.text('Erreur lors de la requête API :'), findsNothing);
    });
  });
}
