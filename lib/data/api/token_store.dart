import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Menyimpan token pasien di penyimpanan aman perangkat.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _kunci = 'token_pasien';
  final FlutterSecureStorage _storage;

  Future<String?> baca() async {
    try {
      return await _storage.read(key: _kunci);
    } catch (_) {
      // Data tersimpan rusak (misalnya setelah pemulihan cadangan Android): anggap belum login.
      await _storage.deleteAll();
      return null;
    }
  }

  Future<void> simpan(String token) => _storage.write(key: _kunci, value: token);

  Future<void> hapus() => _storage.delete(key: _kunci);
}
