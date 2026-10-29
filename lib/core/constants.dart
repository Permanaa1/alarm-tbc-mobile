class Konstanta {
  /// Nama aplikasi sengaja netral (tanpa kata TBC) untuk mengurangi stigma.
  static const String namaApp = 'Pengingat Obat';

  /// Alamat API. Diatur saat menjalankan aplikasi lewat --dart-define=API_BASE_URL=...
  /// (sudah disiapkan di .vscode/launch.json). Bawaan: server lokal di komputer yang sama.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  /// true = pakai data tiruan (tanpa server). Dipakai penyempurna desain.
  static const bool pakaiMock = bool.fromEnvironment('PAKAI_MOCK');

  /// Berapa hari riwayat yang diminta dari server saat sinkronisasi.
  static const int jendelaRiwayatHari = 60;

  /// Berapa hari riwayat yang disimpan di HP.
  static const int simpanRiwayatHari = 120;
}
