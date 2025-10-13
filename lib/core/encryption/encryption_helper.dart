import 'dart:math';

class EncryptionHelper {
  /// ✅ Custom String Encryption
  static String encryptString(String input) {
    try {
      int inputLen = input.length;
      int randKey = Random().nextInt(9) + 1; // Generate random key between 1-9

      List<int> inputChr = List<int>.filled(inputLen, 0);

      // Modify characters based on the random key
      for (int i = 0; i < inputLen; i++) {
        inputChr[i] = input.codeUnitAt(i) - randKey;
      }

      // Convert encrypted characters to string
      StringBuffer sb = StringBuffer();
      for (int i in inputChr) {
        sb.write('$i  a');
      }

      // Append encoded key at the end
      sb.write((randKey.toString().codeUnitAt(0)) + 50);

      return sb.toString();
    } catch (e) {
      return "";
    }
  }
  static String decryptString(String input) {
    if (input.isEmpty) {
      return '';
    }

    if (input.length < 5) {
      return '';
    }

    String real = "";
    List<String> dec = input.split("a");
    int x = dec.length;
    int y = x - 1;
    int calc = int.parse(dec[y]) - 50;

    // Convert to character first, then get its string value as an integer
    String randkeyChar = String.fromCharCode(calc);

    // If it's a digit character, parse it as a number, otherwise use ASCII code
    int randkey;
    if (RegExp(r'^\d$').hasMatch(randkeyChar)) {
      // It's a digit character, parse it as integer (e.g., '9' -> 9)
      randkey = int.parse(randkeyChar);
    } else {
      // It's not a digit, use ASCII code
      randkey = calc;
    }

    for (int i = 0; i < y; i++) {
      int charCode = int.parse(dec[i]) + randkey;
      real += String.fromCharCode(charCode);
    }

    return real;
  }


}
