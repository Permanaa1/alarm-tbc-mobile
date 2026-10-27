import 'package:flutter/foundation.dart';

import '../core/tanggal.dart';
import '../data/models/jadwal_item.dart';
import '../data/models/profil.dart';
import '../data/repositories/pasien_repository.dart';

enum StatusApp { memuat, belumAktif, perluConsent, siap }

/// Satu-satunya sumber keadaan aplikasi. Layar hanya membaca ini dan memanggil method-nya.
class AppState extends ChangeNotifier {
  AppState(this._repo);

  final PasienRepository _repo;

  StatusApp status = StatusApp.memuat;
  Profil? profil;
  List<JadwalItem> jadwal = [];
  List<JadwalItem> riwayat = [];
  bool sedangProses = false;
  String? pesanError;

  List<JadwalItem> get jadwalHariIni =>
      jadwal.where((j) => samaHari(j.tanggal, DateTime.now())).toList();

  /// Jadwal minum hari ini yang paling awal dan belum tercatat.
  JadwalItem? get berikutnya {
    for (final j in jadwalHariIni) {
      if (j.jenis == 'minum' && j.status == null) return j;
    }
    return null;
  }

  Future<void> mulai() async {
    try {
      if (await _repo.sudahAktif()) {
        profil = await _repo.ambilProfil();
        await _tentukanLangkah();
      } else {
        status = StatusApp.belumAktif;
      }
    } catch (e) {
      pesanError = _pesan(e);
      status = StatusApp.belumAktif;
    }
    notifyListeners();
  }

  Future<bool> aktivasi(String kode) async {
    sedangProses = true;
    pesanError = null;
    notifyListeners();
    try {
      profil = await _repo.aktivasi(kode);
      await _tentukanLangkah();
      return true;
    } catch (e) {
      pesanError = _pesan(e);
      return false;
    } finally {
      sedangProses = false;
      notifyListeners();
    }
  }

  Future<void> setujuConsent() async {
    sedangProses = true;
    pesanError = null;
    notifyListeners();
    try {
      profil = await _repo.setujuiConsent();
      await _tentukanLangkah();
    } catch (e) {
      pesanError = _pesan(e);
    } finally {
      sedangProses = false;
      notifyListeners();
    }
  }

  Future<void> muatData() async {
    jadwal = await _repo.ambilJadwal();
    riwayat = await _repo.ambilRiwayat();
  }

  Future<void> segarkan() async {
    try {
      pesanError = null;
      await muatData();
    } catch (e) {
      pesanError = _pesan(e);
    }
    notifyListeners();
  }

  Future<void> tandaiSudahMinum(JadwalItem item) async {
    sedangProses = true;
    pesanError = null;
    notifyListeners();
    try {
      await _repo.catatMinum(item.id);
      await muatData();
    } catch (e) {
      pesanError = _pesan(e);
    } finally {
      sedangProses = false;
      notifyListeners();
    }
  }

  Future<void> keluar() async {
    await _repo.keluar();
    profil = null;
    jadwal = [];
    riwayat = [];
    pesanError = null;
    status = StatusApp.belumAktif;
    notifyListeners();
  }

  Future<void> _tentukanLangkah() async {
    if (profil != null && !profil!.consentDisetujui) {
      status = StatusApp.perluConsent;
    } else {
      await muatData();
      status = StatusApp.siap;
    }
  }

  String _pesan(Object e) =>
      e is AppException ? e.pesan : 'Terjadi kesalahan. Coba lagi.';
}
