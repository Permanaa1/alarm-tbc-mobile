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

/// Masalah sementara (tidak ada sinyal, server sibuk). Aman dicoba lagi nanti.
class JaringanException extends AppException {
  const JaringanException([
    super.pesan =
    'Tidak bisa terhubung ke server. Periksa sinyal atau kuota internet, lalu coba lagi.',
  ]);
}

/// Gambaran keadaan sinkronisasi, untuk ditampilkan di layar.
class StatusSinkron {
  const StatusSinkron({
    this.memakaiDataLokal = false,
    this.terakhirSinkron,
    this.jumlahAntrean = 0,
    this.idBelumTerkirim = const <int>{},
  });

  /// true bila data yang tampil berasal dari penyimpanan HP karena gagal terhubung.
  final bool memakaiDataLokal;

  /// Waktu terakhir jadwal berhasil diperbarui dari server.
  final DateTime? terakhirSinkron;

  /// Jumlah catatan "sudah minum" yang belum terkirim.
  final int jumlahAntrean;

  /// ID jadwal yang konfirmasinya belum terkirim.
  final Set<int> idBelumTerkirim;
}

/// Kontrak data aplikasi. Ada dua pelaksana:
/// MockPasienRepository (data tiruan) dan SinkronPasienRepository (API + penyimpanan HP).
abstract class PasienRepository {
  Future<bool> sudahAktif();
  Future<Profil> aktivasi(String kode);

  /// [utamakanLokal] true = bila ada salinan di HP, langsung dikembalikan tanpa menunggu jaringan.
  Future<Profil> ambilProfil({bool utamakanLokal = false});
  Future<Profil> setujuiConsent();

  /// Jadwal dari hari ini ke depan. Bila tidak ada jaringan, memakai salinan di HP.
  Future<List<JadwalItem>> ambilJadwal({bool utamakanLokal = false});

  /// Riwayat minum (hari-hari sebelumnya dan yang sudah tercatat), dari penyimpanan HP.
  Future<List<JadwalItem>> ambilRiwayat();

  /// Menyimpan konfirmasi di HP dulu (instan), pengiriman ke server menyusul.
  Future<void> catatMinum(int jadwalId);

  /// Mengirim catatan yang menunggu. Gagal jaringan tidak menimbulkan error.
  Future<void> kirimAntrean();

  Future<void> keluar();

  StatusSinkron get statusSinkron;
}