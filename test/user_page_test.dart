import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/user_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('UserPage Widget Tests', () {
    late UserPage userPage;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      userPage = UserPage(
        user_name: 'test_user',
        key: UniqueKey(),
        firestore: fakeFirestore,
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

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify that the degree difference is updated in the UI
      expect(find.text('1'), findsOneWidget);

      // Check that the set method is not called on the Firestore mock
      expect(fakeFirestore.collections.isEmpty, true);
      expect(fakeFirestore.documents.isEmpty, true);
      expect(fakeFirestore.writes, isEmpty);
    });

    testWidgets('Decrement button decreases degree difference',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: userPage,
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Verify that the degree difference is updated in the UI
      expect(find.text('-1'), findsOneWidget);

      // Check that the set method is not called on the Firestore mock
      expect(fakeFirestore.collections.isEmpty, true);
      expect(fakeFirestore.documents.isEmpty, true);
      expect(fakeFirestore.writes, isEmpty);
    });
  });
}
