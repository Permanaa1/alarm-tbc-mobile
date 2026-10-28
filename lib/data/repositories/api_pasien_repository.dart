import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/uuid.dart';
import '../api/api_client.dart';
import '../api/token_store.dart';
import '../models/jadwal_item.dart';
import '../models/profil.dart';
import 'pasien_repository.dart';

/// Pelaksana yang memanggil API Laravel (/api/v1).
///
/// Catatan Batch 7B: semua pemanggilan langsung online. Antrean offline dan database
/// lokal (riwayat lengkap) menyusul di Batch 7C.
class ApiPasienRepository implements PasienRepository {
  ApiPasienRepository(this._api, this._token);

  final ApiClient _api;
  final TokenStore _token;

  List<JadwalItem> _jadwalTerakhir = [];

  /// Membungkus pemanggilan: kesalahan Dio dipetakan, token dihapus bila sesi berakhir.
  Future<T> _panggil<T>(Future<T> Function() aksi) async {
    try {
      return await aksi();
    } on DioException catch (e) {
      final ex = petakanError(e);
      if (ex is SesiBerakhirException) {
        await _token.hapus();
      }
      throw ex;
    }
  }

  @override
  Future<bool> sudahAktif() async => (await _token.baca()) != null;

  @override
  Future<Profil> aktivasi(String kode) async {
    final bersih = kode.trim();
    if (bersih.isEmpty) {
      throw const AppException('Masukkan kode dari petugas.');
    }

    return _panggil(() async {
      final res = await _api.dio.post<Map<String, dynamic>>(
        '/aktivasi',
        data: {
          'kode': bersih,
          'nama_perangkat': 'Pengingat Obat (${defaultTargetPlatform.name})',
        },
      );
      final data = res.data!;
      await _token.simpan(data['token'] as String);
      return Profil.fromJson(data['profil'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Profil> ambilProfil() => _panggil(() async {
        final res = await _api.dio.get<Map<String, dynamic>>('/profil');
        return Profil.fromJson(res.data!);
      });

  @override
  Future<Profil> setujuiConsent() async {
    await _panggil(() => _api.dio.post<Map<String, dynamic>>(
          '/consent',
          data: {'setuju': true},
        ));
    return ambilProfil();
  }

  @override
  Future<List<JadwalItem>> ambilJadwal() => _panggil(() async {
        final res = await _api.dio.get<Map<String, dynamic>>('/jadwal');
        final daftar = (res.data!['jadwal'] as List<dynamic>)
            .map((e) => JadwalItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _jadwalTerakhir = daftar;
        return daftar;
      });

  /// Sementara: hanya jadwal (hari ini ke depan) yang sudah tercatat.
  /// Riwayat hari-hari sebelumnya baru tersedia setelah database lokal (Batch 7C).
  @override
  Future<List<JadwalItem>> ambilRiwayat() async {
    final daftar = _jadwalTerakhir.where((j) => j.status != null).toList();
    daftar.sort((a, b) => b.waktu.compareTo(a.waktu));
    return daftar;
  }

  @override
  Future<void> catatMinum(int jadwalId) => _panggil(() async {
        final res = await _api.dio.post<Map<String, dynamic>>(
          '/log-minum/sinkron',
          data: {
            'items': [
              {
                'client_uuid': buatUuidV4(),
                'jadwal_id': jadwalId,
                'status': 'diminum',
                // UTC agar server menghitung waktu lokal dengan benar di zona waktu mana pun
                'waktu_konfirmasi': DateTime.now().toUtc().toIso8601String(),
              },
            ],
          },
        );

        final hasil = (res.data!['hasil'] as List<dynamic>).first as Map<String, dynamic>;
        if (hasil['hasil'] == 'ditolak') {
          throw const AppException(
            'Jadwal ini sudah berubah. Tarik layar ke bawah untuk memperbarui.',
          );
        }
      });

  /// Hanya menghapus token di HP ini. Token di server dicabut otomatis saat kode baru dipakai.
  @override
  Future<void> keluar() async {
    await _token.hapus();
    _jadwalTerakhir = [];
  }
}
