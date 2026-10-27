import '../../core/tanggal.dart';

class Resep {
  const Resep({
    required this.namaObat,
    required this.dosisTeks,
    required this.fase,
    this.tglMulai,
    this.tglSelesai,
  });

  final String namaObat;
  final String dosisTeks; // teks apa adanya dari resep dokter, tidak dihitung aplikasi
  final String fase; // intensif | lanjutan
  final DateTime? tglMulai;
  final DateTime? tglSelesai;

  factory Resep.fromJson(Map<String, dynamic> json) => Resep(
        namaObat: json['nama_obat'] as String,
        dosisTeks: json['dosis_teks'] as String,
        fase: json['fase'] as String,
        tglMulai: parseTanggal(json['tgl_mulai']),
        tglSelesai: parseTanggal(json['tgl_selesai']),
      );
}
