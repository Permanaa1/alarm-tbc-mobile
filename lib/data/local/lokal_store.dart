import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/antrean_item.dart';
import '../models/jadwal_item.dart';
import '../models/profil.dart';

/// Penyimpanan lokal di HP. Dibuat sebagai kontrak agar mudah diganti
/// (misalnya ke SQLite) tanpa mengubah bagian lain aplikasi.
abstract class LokalStore {
  Future<Profil?> bacaProfil();
  Future<void> simpanProfil(Profil profil);

  Future<List<JadwalItem>> bacaJadwal();
  Future<void> simpanJadwal(List<JadwalItem> daftar);

  Future<List<AntreanItem>> bacaAntrean();
  Future<void> simpanAntrean(List<AntreanItem> daftar);

  Future<DateTime?> bacaWaktu(String kunci);
  Future<void> simpanWaktu(String kunci, DateTime waktu);

  Future<void> hapusSemua();
}

/// Pelaksana memakai shared_preferences (teks JSON). Cukup untuk data sekecil ini
/// (ratusan baris jadwal) dan berjalan di Android maupun Chrome.
class PrefsLokalStore implements LokalStore {
  static const String _kProfil = 'lokal_profil_v1';
  static const String _kJadwal = 'lokal_jadwal_v1';
  static const String _kAntrean = 'lokal_antrean_v1';
  static const String _kWaktuAwalan = 'lokal_waktu_';
  static const List<String> _kunciWaktu = ['sinkron', 'riwayat'];

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  List<dynamic>? _bacaDaftar(String? teks) {
    if (teks == null) return null;
    try {
      return jsonDecode(teks) as List<dynamic>;
    } catch (_) {
      return null; // data rusak dianggap kosong
    }
  }

  @override
  Future<Profil?> bacaProfil() async {
    final teks = (await _prefs).getString(_kProfil);
    if (teks == null) return null;
    try {
      return Profil.fromJson(jsonDecode(teks) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> simpanProfil(Profil profil) async {
    final prefs = await _prefs;
    await prefs.setString(_kProfil, jsonEncode(profil.toJson()));
  }

  @override
  Future<List<JadwalItem>> bacaJadwal() async {
    final daftar = _bacaDaftar((await _prefs).getString(_kJadwal));
    if (daftar == null) return [];
    try {
      return daftar
          .map((e) => JadwalItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> simpanJadwal(List<JadwalItem> daftar) async {
    final prefs = await _prefs;
    await prefs.setString(
      _kJadwal,
      jsonEncode(daftar.map((j) => j.toJson()).toList()),
    );
  }

  @override
  Future<List<AntreanItem>> bacaAntrean() async {
    final daftar = _bacaDaftar((await _prefs).getString(_kAntrean));
    if (daftar == null) return [];
    try {
      return daftar
          .map((e) => AntreanItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> simpanAntrean(List<AntreanItem> daftar) async {
    final prefs = await _prefs;
    await prefs.setString(
      _kAntrean,
      jsonEncode(daftar.map((a) => a.toJson()).toList()),
    );
  }

  @override
  Future<DateTime?> bacaWaktu(String kunci) async {
    final teks = (await _prefs).getString('$_kWaktuAwalan$kunci');
    if (teks == null) return null;
    return DateTime.tryParse(teks)?.toLocal();
  }

  @override
  Future<void> simpanWaktu(String kunci, DateTime waktu) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_kWaktuAwalan$kunci',
      waktu.toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> hapusSemua() async {
    final prefs = await _prefs;
    await prefs.remove(_kProfil);
    await prefs.remove(_kJadwal);
    await prefs.remove(_kAntrean);
    for (final k in _kunciWaktu) {
      await prefs.remove('$_kWaktuAwalan$k');
    }
  }
}
