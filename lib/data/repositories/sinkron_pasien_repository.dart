import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants.dart';
import '../../core/tanggal.dart';
import '../../core/uuid.dart';
import '../api/pasien_api.dart';
import '../api/token_store.dart';
import '../local/lokal_store.dart';
import '../models/antrean_item.dart';
import '../models/jadwal_item.dart';
import '../models/profil.dart';
import 'pasien_repository.dart';

/// Offline-first:
/// - Konfirmasi "sudah minum" disimpan di HP dulu, lalu dikirim ke server saat ada koneksi.
/// - Jadwal, riwayat, dan profil disalin ke HP, sehingga aplikasi tetap bisa dibuka tanpa kuota.
/// - Pengiriman memakai client_uuid, jadi mengirim ulang tidak membuat data ganda di server.
class SinkronPasienRepository implements PasienRepository {
  SinkronPasienRepository(this._api, this._lokal, this._token);

  final PasienApi _api;
  final LokalStore _lokal;
  final TokenStore _token;

  static const String _kSinkron = 'sinkron';
  static const String _kRiwayat = 'riwayat';

  bool _memakaiLokal = false;
  DateTime? _terakhirSinkron;
  int _jumlahAntrean = 0;
  Set<int> _idBelumTerkirim = <int>{};

  // Semua operasi yang membaca lalu menulis antrean dijalankan satu per satu,
  // agar catatan baru tidak tertimpa oleh proses pengiriman yang sedang berjalan.
  Future<void> _antrian = Future<void>.value();

  Future<T> _serial<T>(Future<T> Function() aksi) {
    final selesai = Completer<T>();
    _antrian = _antrian.then((_) async {
      try {
        selesai.complete(await aksi());
      } catch (e, s) {
        selesai.completeError(e, s);
      }
    });
    return selesai.future;
  }

  @override
  StatusSinkron get statusSinkron => StatusSinkron(
        memakaiDataLokal: _memakaiLokal,
        terakhirSinkron: _terakhirSinkron,
        jumlahAntrean: _jumlahAntrean,
        idBelumTerkirim: _idBelumTerkirim,
      );

  Future<void> _segarkanStatus() async {
    final antrean = await _lokal.bacaAntrean();
    _jumlahAntrean = antrean.length;
    _idBelumTerkirim = antrean.map((a) => a.jadwalId).toSet();
    _terakhirSinkron = await _lokal.bacaWaktu(_kSinkron);
  }

  Future<void> _bersihkanSesi() async {
    await _token.hapus();
    await _lokal.hapusSemua();
    _memakaiLokal = false;
    _terakhirSinkron = null;
    _jumlahAntrean = 0;
    _idBelumTerkirim = <int>{};
  }

  // ---------------- sesi dan profil ----------------

  @override
  Future<bool> sudahAktif() async {
    final ada = (await _token.baca()) != null;
    if (ada) {
      await _segarkanStatus();
    }
    return ada;
  }

  @override
  Future<Profil> aktivasi(String kode) async {
    final bersih = kode.trim();
    if (bersih.isEmpty) {
      throw const AppException('Masukkan kode dari petugas.');
    }

    final hasil = await _api.aktivasi(bersih);

    // Aktivasi baru = awal yang baru. Data lokal lama (mungkin milik pasien lain) dibuang.
    await _lokal.hapusSemua();
    await _token.simpan(hasil.token);
    await _lokal.simpanProfil(hasil.profil);

    _memakaiLokal = false;
    await _segarkanStatus();
    return hasil.profil;
  }

  @override
  Future<Profil> ambilProfil({bool utamakanLokal = false}) async {
    if (utamakanLokal) {
      final cache = await _lokal.bacaProfil();
      if (cache != null) return cache;
    }

    try {
      final profil = await _api.profil();
      await _lokal.simpanProfil(profil);
      return profil;
    } on SesiBerakhirException {
      await _bersihkanSesi();
      rethrow;
    } on JaringanException {
      final cache = await _lokal.bacaProfil();
      if (cache != null) {
        _memakaiLokal = true;
        return cache;
      }
      rethrow;
    }
  }

  @override
  Future<Profil> setujuiConsent() async {
    try {
      await _api.consent();
    } on SesiBerakhirException {
      await _bersihkanSesi();
      rethrow;
    }
    return ambilProfil();
  }

  // ---------------- jadwal dan riwayat ----------------

  @override
  Future<List<JadwalItem>> ambilJadwal({bool utamakanLokal = false}) =>
      _serial(() => _ambilJadwal(utamakanLokal));

  Future<List<JadwalItem>> _ambilJadwal(bool utamakanLokal) async {
    if (utamakanLokal) {
      final lokal = await _lokal.bacaJadwal();
      if (lokal.isNotEmpty) {
        return _mendatang(await _terapkanAntrean(lokal));
      }
    }

    try {
      // Kirim dulu catatan yang tertunda, supaya status dari server sudah mutakhir.
      await _kirimAntreanInternal();

      final dariServer = await _api.jadwal();

      var riwayatServer = <JadwalItem>[];
      final terakhirRiwayat = await _lokal.bacaWaktu(_kRiwayat);
      final perluRiwayat = terakhirRiwayat == null ||
          DateTime.now().difference(terakhirRiwayat) > const Duration(hours: 12);
      if (perluRiwayat) {
        try {
          riwayatServer = await _api.riwayat(Konstanta.jendelaRiwayatHari);
          await _lokal.simpanWaktu(_kRiwayat, DateTime.now());
        } on JaringanException {
          // Riwayat gagal diambil tidak menggagalkan pembaruan jadwal.
        }
      }

      final antrean = await _lokal.bacaAntrean();
      final gabungan = _gabung(
        await _lokal.bacaJadwal(),
        riwayatServer,
        dariServer,
        antrean,
      );

      await _lokal.simpanJadwal(gabungan);
      await _lokal.simpanWaktu(_kSinkron, DateTime.now());
      _memakaiLokal = false;
      await _segarkanStatus();

      return _mendatang(gabungan);
    } on SesiBerakhirException {
      await _bersihkanSesi();
      rethrow;
    } on JaringanException {
      _memakaiLokal = true;
      await _segarkanStatus();

      final lokal = await _lokal.bacaJadwal();
      if (lokal.isEmpty) {
        rethrow; // belum ada salinan sama sekali
      }
      return _mendatang(await _terapkanAntrean(lokal));
    }
  }

  @override
  Future<List<JadwalItem>> ambilRiwayat() async {
    final lokal = await _terapkanAntrean(await _lokal.bacaJadwal());
    final h = hariIni();

    final daftar = lokal
        .where((j) =>
            j.jenis == 'minum' && (j.tanggal.isBefore(h) || j.status != null))
        .toList();
    daftar.sort((a, b) => b.waktu.compareTo(a.waktu));
    return daftar;
  }

  List<JadwalItem> _mendatang(List<JadwalItem> daftar) {
    final h = hariIni();
    return daftar.where((j) => !j.tanggal.isBefore(h)).toList();
  }

  /// Menimpa status dengan catatan yang masih menunggu dikirim (server belum tahu).
  Future<List<JadwalItem>> _terapkanAntrean(List<JadwalItem> daftar) async {
    final antrean = await _lokal.bacaAntrean();
    if (antrean.isEmpty) return daftar;

    final status = {for (final a in antrean) a.jadwalId: a.status};
    return daftar
        .map((j) => status.containsKey(j.id) && !j.sudahMinum
            ? j.copyWith(status: status[j.id])
            : j)
        .toList();
  }

  /// Aturan penggabungan:
  /// - Hari sebelum hari ini: arsip lokal, dilengkapi/ditimpa riwayat dari server.
  /// - Hari ini ke depan: sepenuhnya dari server (jadwal yang dihapus petugas ikut hilang).
  /// - Catatan yang belum terkirim ditampilkan sebagai "diminum".
  List<JadwalItem> _gabung(
    List<JadwalItem> lokal,
    List<JadwalItem> riwayatServer,
    List<JadwalItem> jadwalServer,
    List<AntreanItem> antrean,
  ) {
    final h = hariIni();
    final batasArsip =
        DateTime(h.year, h.month, h.day - Konstanta.simpanRiwayatHari);
    final peta = <int, JadwalItem>{};

    for (final j in lokal) {
      if (j.tanggal.isBefore(h) && !j.tanggal.isBefore(batasArsip)) {
        peta[j.id] = j;
      }
    }
    for (final j in riwayatServer) {
      peta[j.id] = j;
    }
    for (final j in jadwalServer) {
      peta[j.id] = j;
    }

    final status = {for (final a in antrean) a.jadwalId: a.status};
    final hasil = peta.values
        .map((j) => status.containsKey(j.id) && !j.sudahMinum
            ? j.copyWith(status: status[j.id])
            : j)
        .toList();
    hasil.sort((a, b) => a.waktu.compareTo(b.waktu));
    return hasil;
  }

  // ---------------- konfirmasi minum dan antrean ----------------

  @override
  Future<void> catatMinum(int jadwalId) => _serial(() async {
        final antrean = await _lokal.bacaAntrean();
        if (antrean.any((a) => a.jadwalId == jadwalId)) {
          return; // sudah dicatat, abaikan tekanan ganda
        }

        antrean.add(AntreanItem(
          clientUuid: buatUuidV4(),
          jadwalId: jadwalId,
          status: 'diminum',
          waktuKonfirmasi: DateTime.now().toUtc(),
        ));
        await _lokal.simpanAntrean(antrean);

        // Perbarui salinan jadwal agar status langsung berubah di layar.
        final jadwal = await _lokal.bacaJadwal();
        await _lokal.simpanJadwal(
          jadwal
              .map((j) => j.id == jadwalId ? j.copyWith(status: 'diminum') : j)
              .toList(),
        );
        await _segarkanStatus();
      });

  @override
  Future<void> kirimAntrean() => _serial(() async {
        try {
          await _kirimAntreanInternal();
        } on JaringanException {
          // Tetap di antrean, dicoba lagi nanti.
        } on SesiBerakhirException {
          await _bersihkanSesi();
          rethrow;
        }
        await _segarkanStatus();
      });

  Future<void> _kirimAntreanInternal() async {
    var antrean = await _lokal.bacaAntrean();

    while (antrean.isNotEmpty) {
      final potongan = antrean.take(50).toList();

      List<HasilKirimItem> hasil;
      try {
        hasil = await _api.sinkron(potongan);
      } on JaringanException {
        rethrow;
      } on SesiBerakhirException {
        rethrow;
      } on AppException {
        // Seluruh kiriman ditolak (bukan masalah jaringan): coba satu per satu
        // dan buang yang bermasalah agar antrean tidak macet selamanya.
        hasil = await _kirimSatuSatu(potongan);
      }

      // dicatat, sudah_ada, dan ditolak sama-sama berarti urusan item ini selesai.
      final selesai = hasil.map((h) => h.clientUuid).toSet();
      antrean = antrean.where((a) => !selesai.contains(a.clientUuid)).toList();
      await _lokal.simpanAntrean(antrean);

      if (selesai.isEmpty) break; // pengaman agar tidak berputar tanpa akhir
    }

    await _segarkanStatus();
  }

  Future<List<HasilKirimItem>> _kirimSatuSatu(List<AntreanItem> items) async {
    final hasil = <HasilKirimItem>[];

    for (final item in items) {
      try {
        hasil.addAll(await _api.sinkron([item]));
      } on JaringanException {
        rethrow;
      } on SesiBerakhirException {
        rethrow;
      } on AppException catch (e) {
        debugPrint('Catatan minum dibuang karena ditolak server: ${e.pesan}');
        hasil.add(HasilKirimItem(item.clientUuid, 'ditolak', 'dibuang'));
      }
    }

    return hasil;
  }

  @override
  Future<void> keluar() => _serial(() async {
        await _bersihkanSesi();
      });
}
