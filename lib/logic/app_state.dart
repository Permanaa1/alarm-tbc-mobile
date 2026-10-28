import 'package:flutter/foundation.dart';

import '../core/tanggal.dart';
import '../data/models/jadwal_item.dart';
import '../data/models/profil.dart';
import '../data/repositories/pasien_repository.dart';

enum StatusApp { memuat, belumAktif, perluConsent, siap, gagalMuat }

/// Satu-satunya sumber keadaan aplikasi. Layar hanya membaca ini dan memanggil method-nya.
class AppState extends ChangeNotifier {
  AppState(this._repo);

  final PasienRepository _repo;

  /// Tombol "Sudah minum" aktif mulai sekian menit sebelum jam minum.
  static const int _menitSebelumJam = 60;

  StatusApp status = StatusApp.memuat;
  Profil? profil;
  List<JadwalItem> jadwal = [];
  List<JadwalItem> riwayat = [];
  bool sedangProses = false;
  String? pesanError;

  /// Jadwal hari ini, terurut dari pagi ke malam.
  List<JadwalItem> get jadwalHariIni {
    final daftar =
        jadwal.where((j) => samaHari(j.tanggal, DateTime.now())).toList();
    daftar.sort((a, b) => a.waktu.compareTo(b.waktu));
    return daftar;
  }

  List<JadwalItem> get _minumHariIni =>
      jadwalHariIni.where((j) => j.jenis == 'minum').toList();

  List<JadwalItem> get _belumTercatatHariIni =>
      _minumHariIni.where((j) => j.status == null).toList();

  int get jumlahDosisHariIni => _minumHariIni.length;

  int get dosisSelesaiHariIni => _minumHariIni.where((j) => j.sudahMinum).length;

  /// Dosis yang boleh dikonfirmasi sekarang: sudah waktunya (atau kurang dari 1 jam lagi).
  /// Bila ada beberapa, diambil yang paling baru. Dosis lebih awal yang belum tercatat
  /// dibiarkan, tidak dianggap sudah diminum.
  JadwalItem? get dosisSiapDiminum {
    final batas = DateTime.now().add(const Duration(minutes: _menitSebelumJam));
    final siap =
        _belumTercatatHariIni.where((j) => !j.waktu.isAfter(batas)).toList();
    return siap.isEmpty ? null : siap.last;
  }

  /// Dosis yang ditampilkan di kartu "Obat berikutnya".
  JadwalItem? get berikutnya {
    final siap = dosisSiapDiminum;
    if (siap != null) return siap;
    final belum = _belumTercatatHariIni;
    return belum.isEmpty ? null : belum.first;
  }

  /// Dipanggil saat aplikasi dibuka.
  Future<void> mulai() async {
    try {
      if (await _repo.sudahAktif()) {
        profil = await _repo.ambilProfil();
        await _tentukanLangkah();
      } else {
        status = StatusApp.belumAktif;
      }
    } catch (e) {
      if (!_tanganiSesi(e)) {
        pesanError = _pesan(e);
        status = StatusApp.gagalMuat;
      }
    }
    notifyListeners();
  }

  /// Tombol "Coba lagi" pada layar gagal memuat.
  Future<void> ulangi() async {
    status = StatusApp.memuat;
    pesanError = null;
    notifyListeners();
    await mulai();
  }

  Future<bool> aktivasi(String kode) async {
    sedangProses = true;
    pesanError = null;
    notifyListeners();

    try {
      profil = await _repo.aktivasi(kode);
    } catch (e) {
      pesanError = _pesan(e);
      sedangProses = false;
      notifyListeners();
      return false;
    }

    await _lanjutkan();
    sedangProses = false;
    notifyListeners();
    return true;
  }

  Future<void> setujuConsent() async {
    sedangProses = true;
    pesanError = null;
    notifyListeners();

    try {
      profil = await _repo.setujuiConsent();
    } catch (e) {
      if (!_tanganiSesi(e)) pesanError = _pesan(e);
      sedangProses = false;
      notifyListeners();
      return;
    }

    await _lanjutkan();
    sedangProses = false;
    notifyListeners();
  }

  Future<void> muatData() async {
    jadwal = await _repo.ambilJadwal();
    riwayat = await _repo.ambilRiwayat();
  }

  Future<void> segarkan() async {
    pesanError = null;
    try {
      await muatData();
    } catch (e) {
      if (!_tanganiSesi(e)) pesanError = _pesan(e);
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
      if (!_tanganiSesi(e)) {
        pesanError = _pesan(e);
        try {
          await muatData();
        } catch (_) {
          // abaikan: pesan kesalahan utama sudah ditampilkan
        }
      }
    } finally {
      sedangProses = false;
      notifyListeners();
    }
  }

  Future<void> keluar() async {
    await _repo.keluar();
    _reset();
    status = StatusApp.belumAktif;
    notifyListeners();
  }

  // ---------------- internal ----------------

  /// Menentukan layar berikutnya. Gagal jaringan -> layar "Coba lagi" (token tetap tersimpan).
  Future<void> _lanjutkan() async {
    try {
      await _tentukanLangkah();
    } catch (e) {
      if (!_tanganiSesi(e)) {
        pesanError = _pesan(e);
        status = StatusApp.gagalMuat;
      }
    }
  }

  Future<void> _tentukanLangkah() async {
    if (profil != null && !profil!.consentDisetujui) {
      status = StatusApp.perluConsent;
    } else {
      await muatData();
      status = StatusApp.siap;
    }
  }

  /// Bila sesi berakhir: kembali ke layar aktivasi dengan pesan penjelasan.
  bool _tanganiSesi(Object e) {
    if (e is SesiBerakhirException) {
      _reset();
      pesanError = e.pesan;
      status = StatusApp.belumAktif;
      return true;
    }
    return false;
  }

  void _reset() {
    profil = null;
    jadwal = [];
    riwayat = [];
    pesanError = null;
  }

  String _pesan(Object e) =>
      e is AppException ? e.pesan : 'Terjadi kesalahan. Coba lagi.';
}
