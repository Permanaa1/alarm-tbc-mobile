import 'dart:async';

import 'package:flutter/widgets.dart';

import '../core/tanggal.dart';
import '../data/models/jadwal_item.dart';
import '../data/models/profil.dart';
import '../data/repositories/pasien_repository.dart';

enum StatusApp { memuat, belumAktif, perluConsent, siap, gagalMuat }

/// Satu-satunya sumber keadaan aplikasi. Layar hanya membaca ini dan memanggil method-nya.
class AppState extends ChangeNotifier with WidgetsBindingObserver {
  AppState(this._repo) {
    WidgetsBinding.instance.addObserver(this);
  }

  final PasienRepository _repo;

  /// Tombol "Sudah minum" aktif mulai sekian menit sebelum jam minum.
  static const int _menitSebelumJam = 60;

  StatusApp status = StatusApp.memuat;
  Profil? profil;
  List<JadwalItem> jadwal = [];
  List<JadwalItem> riwayat = [];
  bool sedangProses = false;
  String? pesanError;

  /// Keadaan sinkronisasi (offline, antrean kiriman, waktu terakhir diperbarui).
  StatusSinkron sinkron = const StatusSinkron();

  bool get memakaiDataLokal => sinkron.memakaiDataLokal;
  int get jumlahAntrean => sinkron.jumlahAntrean;
  DateTime? get terakhirSinkron => sinkron.terakhirSinkron;
  Set<int> get idBelumTerkirim => sinkron.idBelumTerkirim;

  Timer? _timer;
  bool _menyegarkan = false;
  bool _mengirim = false;

  // ---------------- data turunan untuk tampilan ----------------

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

  // ---------------- alur utama ----------------

  /// Dipanggil saat aplikasi dibuka. Memakai salinan di HP lebih dulu agar layar langsung
  /// tampil, lalu memperbarui dari server di latar belakang.
  Future<void> mulai() async {
    try {
      if (await _repo.sudahAktif()) {
        profil = await _repo.ambilProfil(utamakanLokal: true);
        await _tentukanLangkah(utamakanLokal: true);
      } else {
        status = StatusApp.belumAktif;
      }
    } catch (e) {
      if (!_tanganiSesi(e)) {
        pesanError = _pesan(e);
        status = StatusApp.gagalMuat;
      }
    }

    _ambilStatus();
    notifyListeners();

    if (status == StatusApp.siap) {
      _mulaiPenjadwal();
      unawaited(segarkan());
    }
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
    _ambilStatus();
    notifyListeners();

    if (status == StatusApp.siap) _mulaiPenjadwal();
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
    _ambilStatus();
    notifyListeners();

    if (status == StatusApp.siap) _mulaiPenjadwal();
  }

  Future<void> muatData({bool utamakanLokal = false}) async {
    jadwal = await _repo.ambilJadwal(utamakanLokal: utamakanLokal);
    riwayat = await _repo.ambilRiwayat();
  }

  /// Menyegarkan dari server (tarik layar, kembali ke aplikasi, atau timer).
  /// Bila tidak ada koneksi, data di HP tetap tampil dan banner offline muncul.
  Future<void> segarkan() async {
    if (_menyegarkan) return;
    _menyegarkan = true;
    pesanError = null;

    try {
      profil = await _repo.ambilProfil();
      await muatData();
    } catch (e) {
      if (!_tanganiSesi(e)) pesanError = _pesan(e);
    } finally {
      _menyegarkan = false;
      _ambilStatus();
      notifyListeners();
    }
  }

  /// Konfirmasi "sudah minum": tersimpan di HP seketika, pengiriman ke server menyusul.
  Future<void> tandaiSudahMinum(JadwalItem item) async {
    pesanError = null;

    try {
      await _repo.catatMinum(item.id);
      await muatData(utamakanLokal: true);
    } catch (e) {
      if (!_tanganiSesi(e)) pesanError = _pesan(e);
    }

    _ambilStatus();
    notifyListeners();
    unawaited(_kirimDiamDiam());
  }

  /// Tombol "Kirim sekarang" pada banner.
  Future<void> kirimSekarang() async {
    await _kirimDiamDiam();
    await segarkan();
  }

  Future<void> keluar() async {
    await _repo.keluar();
    _reset();
    status = StatusApp.belumAktif;
    _ambilStatus();
    notifyListeners();
  }

  // ---------------- internal ----------------

  Future<void> _kirimDiamDiam() async {
    if (_mengirim) return;
    _mengirim = true;
    try {
      await _repo.kirimAntrean();
    } catch (e) {
      _tanganiSesi(e);
    } finally {
      _mengirim = false;
      _ambilStatus();
      notifyListeners();
    }
  }

  void _mulaiPenjadwal() {
    _timer ??= Timer.periodic(const Duration(minutes: 2), (_) {
      if (status != StatusApp.siap) return;
      if (jumlahAntrean > 0) {
        unawaited(_kirimDiamDiam());
      } else if (memakaiDataLokal) {
        unawaited(segarkan());
      }
    });
  }

  void _hentikanPenjadwal() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && status == StatusApp.siap) {
      unawaited(segarkan());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hentikanPenjadwal();
    super.dispose();
  }

  void _ambilStatus() {
    sinkron = _repo.statusSinkron;
  }

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

  Future<void> _tentukanLangkah({bool utamakanLokal = false}) async {
    if (profil != null && !profil!.consentDisetujui) {
      status = StatusApp.perluConsent;
    } else {
      await muatData(utamakanLokal: utamakanLokal);
      status = StatusApp.siap;
    }
  }

  /// Bila sesi berakhir: kembali ke layar aktivasi dengan pesan penjelasan.
  bool _tanganiSesi(Object e) {
    if (e is SesiBerakhirException) {
      _reset();
      pesanError = e.pesan;
      status = StatusApp.belumAktif;
      _ambilStatus();
      notifyListeners();
      return true;
    }
    return false;
  }

  void _reset() {
    _hentikanPenjadwal();
    profil = null;
    jadwal = [];
    riwayat = [];
    pesanError = null;
  }

  String _pesan(Object e) =>
      e is AppException ? e.pesan : 'Terjadi kesalahan. Coba lagi.';
}
