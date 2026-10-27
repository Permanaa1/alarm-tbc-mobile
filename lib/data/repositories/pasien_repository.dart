import '../models/jadwal_item.dart';
import '../models/profil.dart';

/// Kesalahan yang pesannya boleh langsung ditampilkan ke pengguna.
class AppException implements Exception {
  const AppException(this.pesan);
  final String pesan;

  @override
  String toString() => pesan;
}

/// Kontrak data aplikasi. Batch 7A memakai MockPasienRepository,
/// Batch 7B menggantinya dengan versi yang memanggil API asli.
abstract class PasienRepository {
  Future<bool> sudahAktif();
  Future<Profil> aktivasi(String kode);
  Future<Profil> ambilProfil();
  Future<Profil> setujuiConsent();
  Future<List<JadwalItem>> ambilJadwal(); // dari hari ini ke depan
  Future<List<JadwalItem>> ambilRiwayat(); // yang sudah lewat / sudah tercatat
  Future<void> catatMinum(int jadwalId);
  Future<void> keluar();
}
