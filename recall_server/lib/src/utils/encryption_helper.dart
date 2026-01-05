import 'package:encrypt/encrypt.dart';
import 'dart:io';

class EncryptionHelper {
  static final _key = Key.fromLength(32); // Generated randomly for dev
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  // NOTE: In production, load this from an environment variable!
  // This is a temporary simpler implementation for the prototype.
  // Ideally: Key.fromBase64(Platform.environment['ENCRYPTION_KEY']!)
  
  static String encrypt(String plainText) {
    if (plainText.isEmpty) return '';
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decrypt(String cipherText) {
    if (cipherText.isEmpty) return '';
    try {
      return _encrypter.decrypt(Encrypted.fromBase64(cipherText), iv: _iv);
    } catch (e) {
      print('Decryption failed: $e');
      return '';
    }
  }
}
