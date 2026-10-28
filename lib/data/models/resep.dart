import '../../core/tanggal.dart';

class Resep {
  const Resep({
    required this.namaObat,
    required this.dosisTeks,
    required this.fase,
    this.jamMinum = const [],
    this.tglMulai,
    this.tglSelesai,
  });

  final String namaObat;
  final String dosisTeks; // teks apa adanya dari resep dokter, tidak dihitung aplikasi
  final String fase; // intensif | lanjutan

  /// Jam minum per hari, contoh ["07:00", "14:00", "21:00"]. Kosong = ikut jam minum pasien.
  final List<String> jamMinum;
  final DateTime? tglMulai;
  final DateTime? tglSelesai;

  factory Resep.fromJson(Map<String, dynamic> json) => Resep(
        namaObat: json['nama_obat'] as String,
        dosisTeks: json['dosis_teks'] as String,
        fase: json['fase'] as String,
        jamMinum: (json['jam_minum'] as List<dynamic>? ?? [])
            .map((e) => _potongJam(e as String))
            .toList(),
        tglMulai: parseTanggal(json['tgl_mulai']),
        tglSelesai: parseTanggal(json['tgl_selesai']),
      );
}

String _potongJam(String jam) => jam.length >= 5 ? jam.substring(0, 5) : jam;
