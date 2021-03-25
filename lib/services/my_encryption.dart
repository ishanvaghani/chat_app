import 'package:encrypt/encrypt.dart' as encrypt;

class MyEncryption {
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static encryptAES(String text) {
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  static decryptAES(String text) {
    encrypt.Encrypted e = encrypt.Encrypted.fromBase64(text);
    return encrypter.decrypt(e, iv: iv);
  }
}
