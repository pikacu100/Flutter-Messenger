import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {

  static Key getKeyFromUid(String uid) {
    final bytes = utf8.encode(uid);
    final digest = sha256.convert(bytes);
    return Key(Uint8List.fromList(digest.bytes));
  }

  static String encrypt(String plainText, String uid) {
    final key = getKeyFromUid(uid);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final combined = iv.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  static String decrypt(String combinedBase64, String uid) {
    final key = getKeyFromUid(uid);
    final bytes = base64Decode(combinedBase64);

    final iv = IV(Uint8List.fromList(bytes.sublist(0, 16)));
    final encryptedBytes = bytes.sublist(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = Encrypted(encryptedBytes);

    return encrypter.decrypt(encrypted, iv: iv);
  }
}
