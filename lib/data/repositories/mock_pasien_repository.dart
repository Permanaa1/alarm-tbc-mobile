import '../../core/tanggal.dart';
import '../models/jadwal_item.dart';
import '../models/profil.dart';
import '../models/resep.dart';
import 'pasien_repository.dart';

/// Data tiruan di memori. Reset setiap aplikasi dimulai ulang (hot restart).
/// Kode uji: ABCD-EFGH (kode apa pun dengan 8 huruf/angka diterima, selain itu ditolak).
/// Data tiruan memakai 3 kali minum sehari agar tampilan multi-dosis bisa dirancang.
class MockPasienRepository implements PasienRepository {
  bool _aktif = false;
  bool _consent = false;
  final Map<int, String> _status = {};
  late final List<JadwalItem> _semua = _buatJadwal();

  static const Duration _tunda = Duration(milliseconds: 500);
  static const List<String> _jamMinum = ['07:00', '14:00', '21:00'];

  List<JadwalItem> _buatJadwal() {
    final h = hariIni();
    final hasil = <JadwalItem>[];
    var id = 1;
    for (var i = -6; i <= 13; i++) {
      for (final jam in _jamMinum) {
        hasil.add(JadwalItem(
          id: id++,
          jenis: 'minum',
          tanggal: DateTime(h.year, h.month, h.day + i),
          jam: jam,
          keterangan: 'OAT KDT Fase Intensif',
          // 3 hari lalu sengaja dibiarkan kosong agar riwayat punya contoh "belum tercatat"
          status: (i < 0 && i != -3) ? 'diminum' : null,
        ));
      }
    }
    return hasil;
  }

  JadwalItem _terapkan(JadwalItem j) =>
      _status.containsKey(j.id) ? j.copyWith(status: _status[j.id]) : j;

  Profil _profil() {
    final h = hariIni();
    return Profil(
      nama: 'Sutrisno (data tiruan)',
      jamMinumDefault: '07:00',
      fotoBuktiAktif: false,
      pmoNama: 'Budi',
      pmoHubungan: 'anak',
      resep: [
        Resep(
          namaObat: 'OAT KDT Fase Intensif',
          dosisTeks: '3 tablet 1x sehari pagi',
          fase: 'intensif',
          jamMinum: _jamMinum,
          tglMulai: h,
          tglSelesai: DateTime(h.year, h.month, h.day + 13),
        ),
      ],
      consentDisetujui: _consent,
      versiConsent: '1.0',
    );
  }

  @override
  Future<bool> sudahAktif() async => _aktif;

  @override
  Future<Profil> aktivasi(String kode) async {
    await Future<void>.delayed(_tunda);
    final bersih = kode.replaceAll('-', '').replaceAll(' ', '').toUpperCase();
    if (bersih.length != 8) {
      throw const AppException(
        'Kode tidak valid atau sudah kedaluwarsa. Minta kode baru ke petugas.',
      );
    }
    _aktif = true;
    return _profil();
  }

  @override
  Future<Profil> ambilProfil() async => _profil();

  @override
  Future<Profil> setujuiConsent() async {
    await Future<void>.delayed(_tunda);
    _consent = true;
    return _profil();
  }

  @override
  Future<List<JadwalItem>> ambilJadwal() async {
    final h = hariIni();
    return _semua
        .map(_terapkan)
        .where((j) => !j.tanggal.isBefore(h))
        .toList();
  }

  @override
  Future<List<JadwalItem>> ambilRiwayat() async {
    final h = hariIni();
    final daftar = _semua
        .map(_terapkan)
        .where((j) => j.tanggal.isBefore(h) || j.status != null)
        .toList();
    daftar.sort((a, b) => b.waktu.compareTo(a.waktu));
    return daftar;
  }

  @override
  Future<void> catatMinum(int jadwalId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _status[jadwalId] = 'diminum';
  }

  @override
  Future<void> keluar() async {
    _aktif = false;
    _consent = false;
    _status.clear();
  }
}
