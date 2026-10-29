import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/antrean_item.dart';
import '../models/jadwal_item.dart';
import '../models/profil.dart';
import 'api_client.dart';

class HasilAktivasi {
  const HasilAktivasi(this.token, this.profil);
  final String token;
  final Profil profil;
}

/// Hasil pengiriman satu catatan: dicatat | sudah_ada | ditolak.
class HasilKirimItem {
  const HasilKirimItem(this.clientUuid, this.hasil, this.alasan);
  final String clientUuid;
  final String hasil;
  final String? alasan;
}

/// Lapisan paling bawah: hanya memanggil API dan mengubah kesalahan jaringan
/// menjadi AppException / JaringanException / SesiBerakhirException.
/// Tidak menyimpan apa pun di HP.
class PasienApi {
  PasienApi(this._klien);

  final ApiClient _klien;

  Future<T> _panggil<T>(Future<T> Function() aksi) async {
    try {
      return await aksi();
    } on DioException catch (e) {
      throw petakanError(e);
    }
  }

  Future<HasilAktivasi> aktivasi(String kode) => _panggil(() async {
        final res = await _klien.dio.post<Map<String, dynamic>>(
          '/aktivasi',
          data: {
            'kode': kode,
            'nama_perangkat': 'Pengingat Obat (${defaultTargetPlatform.name})',
          },
        );
        final data = res.data!;
        return HasilAktivasi(
          data['token'] as String,
          Profil.fromJson(data['profil'] as Map<String, dynamic>),
        );
      });

  Future<Profil> profil() => _panggil(() async {
        final res = await _klien.dio.get<Map<String, dynamic>>('/profil');
        return Profil.fromJson(res.data!);
      });

  Future<void> consent() => _panggil(() async {
        await _klien.dio.post<Map<String, dynamic>>(
          '/consent',
          data: {'setuju': true},
        );
      });

  Future<List<JadwalItem>> jadwal() => _panggil(() async {
        final res = await _klien.dio.get<Map<String, dynamic>>('/jadwal');
        return _daftarJadwal(res.data!);
      });

  Future<List<JadwalItem>> riwayat(int hari) => _panggil(() async {
        final res = await _klien.dio.get<Map<String, dynamic>>(
          '/riwayat',
          queryParameters: {'hari': hari},
        );
        return _daftarJadwal(res.data!);
      });

  Future<List<HasilKirimItem>> sinkron(List<AntreanItem> items) =>
      _panggil(() async {
        final res = await _klien.dio.post<Map<String, dynamic>>(
          '/log-minum/sinkron',
          data: {'items': items.map((i) => i.toJson()).toList()},
        );
        return (res.data!['hasil'] as List<dynamic>).map((e) {
          final m = e as Map<String, dynamic>;
          return HasilKirimItem(
            m['client_uuid'] as String,
            m['hasil'] as String,
            m['alasan'] as String?,
          );
        }).toList();
      });

  List<JadwalItem> _daftarJadwal(Map<String, dynamic> data) =>
      (data['jadwal'] as List<dynamic>)
          .map((e) => JadwalItem.fromJson(e as Map<String, dynamic>))
          .toList();
}
