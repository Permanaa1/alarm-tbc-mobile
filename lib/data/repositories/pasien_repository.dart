import '../models/jadwal_item.dart';
import '../models/profil.dart';

/// Kesalahan yang pesannya boleh langsung ditampilkan ke pengguna.
class AppException implements Exception {
  const AppException(this.pesan);
  final String pesan;

  @override
  String toString() => pesan;
}

/// Token ditolak server (dicabut, kedaluwarsa, atau diganti HP lain).
class SesiBerakhirException extends AppException {
  const SesiBerakhirException()
      : super('Sesi berakhir. Minta kode baru ke petugas untuk masuk lagi.');
}

/// Kontrak data aplikasi. Ada dua pelaksana:
/// MockPasienRepository (data tiruan) dan ApiPasienRepository (API asli).
abstract class PasienRepository {
  Future<bool> sudahAktif();
  Future<Profil> aktivasi(String kode);
  Future<Profil> ambilProfil();
  Future<Profil> setujuiConsent();
  Future<List<JadwalItem>> ambilJadwal(); // dari hari ini ke depan
  Future<List<JadwalItem>> ambilRiwayat(); // yang sudah tercatat
  Future<void> catatMinum(int jadwalId);
  Future<void> keluar();
}
