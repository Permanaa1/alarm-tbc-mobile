/// Satu catatan "sudah minum" yang menunggu dikirim ke server.
class AntreanItem {
  const AntreanItem({
    required this.clientUuid,
    required this.jadwalId,
    required this.status,
    required this.waktuKonfirmasi,
  });

  final String clientUuid; // kunci anti-ganda di server
  final int jadwalId;
  final String status; // diminum | ditunda
  final DateTime waktuKonfirmasi; // saat tombol ditekan (disimpan sebagai UTC)

  factory AntreanItem.fromJson(Map<String, dynamic> json) => AntreanItem(
        clientUuid: json['client_uuid'] as String,
        jadwalId: json['jadwal_id'] as int,
        status: json['status'] as String,
        waktuKonfirmasi: DateTime.parse(json['waktu_konfirmasi'] as String),
      );

  /// Bentuk yang sama dipakai untuk penyimpanan lokal dan untuk dikirim ke API.
  Map<String, dynamic> toJson() => {
        'client_uuid': clientUuid,
        'jadwal_id': jadwalId,
        'status': status,
        'waktu_konfirmasi': waktuKonfirmasi.toUtc().toIso8601String(),
      };
}
