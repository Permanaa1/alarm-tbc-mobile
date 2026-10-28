import 'dart:math';

/// UUID versi 4 (acak). Dipakai sebagai client_uuid agar kiriman ulang tidak tercatat ganda.
String buatUuidV4() {
  final acak = Random.secure();
  final b = List<int>.generate(16, (_) => acak.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40; // versi 4
  b[8] = (b[8] & 0x3f) | 0x80; // varian RFC 4122

  String h(int i) => b[i].toRadixString(16).padLeft(2, '0');

  return '${h(0)}${h(1)}${h(2)}${h(3)}-${h(4)}${h(5)}-${h(6)}${h(7)}-'
      '${h(8)}${h(9)}-${h(10)}${h(11)}${h(12)}${h(13)}${h(14)}${h(15)}';
}
