import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserByEmail(String userEmail) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('user_email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user by email: $e');
    }

    return null;
  }

  Future<bool> authenticateUser(String userEmail, String userPassword) async {
    try {
      // Query the "users" collection to find the user with the specified email
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('user_email', isEqualTo: userEmail)
          .limit(1)
          .get();

      print('Signing in with email and password...');

      // Check if a user with the specified email exists
      if (querySnapshot.docs.isNotEmpty) {
        String userId = querySnapshot.docs.first.id;

        // Fetch the user's document (subcollection) using the user ID
        DocumentSnapshot userSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection(userId) // Use the user ID as the subcollection name
            .doc(userId) // Replace with your actual document ID
            .get();

        // Check if the user's document (subcollection) exists
        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

          // Check if the provided password matches the stored password
          if (userData['user_password'] == userPassword) {
            // Password matches, authentication successful
            return true;
          }
        }
      }
    } catch (e) {
      print('Error authenticating user: $e');
    }

    return false;
  }

  Future<bool> isUserAssociatedWithHouse(String userId, String houseId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        return userData['houses'] != null &&
            userData['houses'][houseId] == true;
      }
    } catch (e) {
      print('Error checking user association with house: $e');
    }

    return false;
  }
}
// Compare this snippet from lib/screens/login_page.dart: