import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

String generateSalt() {
  final random = Random.secure();
  final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
  return base64.encode(saltBytes);
}

String? hashPasswordSync(String password, String salt) {
  try {
    final codec = utf8.encoder;
    final key = codec.convert('$password$salt');
    final hashedBytes = sha256.convert(key);
    return base64.encode(hashedBytes.bytes);
  } catch (e) {
    print('Error hashing password: $e');
    return null;
  }
}

Future<String> hashPassword(String password, String salt) async {
  try {
    final codec = utf8.encoder;
    final key = codec.convert('$password$salt');
    final bytes = Uint8List.fromList(key);
    final hashedBytes = sha256.convert(bytes);
    return base64.encode(hashedBytes.bytes);
  } catch (e) {
    print('Error hashing password: $e');
    return Future.error('Error hashing password');
  }
}
