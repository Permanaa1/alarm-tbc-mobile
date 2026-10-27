/// Mengubah teks "2026-10-26" menjadi DateTime lokal (tengah malam). Null bila kosong.
DateTime? parseTanggal(dynamic nilai) =>
    nilai == null ? null : DateTime.parse(nilai as String);

/// Hari ini, jam 00:00 (waktu perangkat).
DateTime hariIni() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

bool samaHari(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
