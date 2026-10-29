import '../../core/tanggal.dart';

class JadwalItem {
  const JadwalItem({
    required this.id,
    required this.jenis,
    required this.tanggal,
    required this.jam,
    this.keterangan,
    this.status,
  });

  final int id;
  final String jenis; // minum | kontrol | ambil_obat
  final DateTime tanggal; // hanya tanggal (00:00)
  final String jam; // "07:00"
  final String? keterangan;

  /// diminum | ditunda | terlewat | belum_terkonfirmasi | null (belum ada catatan)
  final String? status;

  factory JadwalItem.fromJson(Map<String, dynamic> json) => JadwalItem(
        id: json['id'] as int,
        jenis: json['jenis'] as String,
        tanggal: parseTanggal(json['tanggal'])!,
        jam: json['jam'] as String,
        keterangan: json['keterangan'] as String?,
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'jenis': jenis,
        'tanggal': formatTanggal(tanggal),
        'jam': jam,
        'keterangan': keterangan,
        'status': status,
      };

  JadwalItem copyWith({String? status}) => JadwalItem(
        id: id,
        jenis: jenis,
        tanggal: tanggal,
        jam: jam,
        keterangan: keterangan,
        status: status ?? this.status,
      );

  /// Tanggal dan jam digabung (waktu perangkat).
  DateTime get waktu {
    final bagian = jam.split(':');
    return DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
      int.parse(bagian[0]),
      int.parse(bagian[1]),
    );
  }

  bool get sudahMinum => status == 'diminum';

  // Getters for compatibility with reference UI
  String get date => formatTanggal(tanggal);
  String get time => jam;
  int get scheduleId => id;
  bool get synced => status != null; // Simplification for UI
}
