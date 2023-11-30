import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';

void main() {
  group('UserPage Widget Tests', () {
    late UserPage userPage;
    late MockFirestoreInstance mockFirestore;

    setUp(() {
      mockFirestore = MockFirestoreInstance();
      userPage = UserPage(
        user_name: 'test_user',
        key: UniqueKey(),
        firestore: mockFirestore,
      );
    });

    testWidgets('Widget builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: userPage,
        ),
      );

      expect(find.text('User Page'), findsOneWidget);
    });

    testWidgets('Increment button increases degree difference',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: userPage,
        ),
      );

      await tester
          .tap(find.byIcon(Icons.add)); // Make sure Icons.add is available
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Decrement button decreases degree difference',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: userPage,
        ),
      );

      await tester.tap(
          find.byIcon(Icons.remove)); // Make sure Icons.remove is available
      await tester.pump();

      expect(find.text('-1'), findsOneWidget);
    });
  });
}
