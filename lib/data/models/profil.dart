import 'resep.dart';

class Profil {
  const Profil({
    required this.nama,
    required this.jamMinumDefault,
    required this.fotoBuktiAktif,
    required this.resep,
    required this.consentDisetujui,
    required this.versiConsent,
    this.pmoNama,
    this.pmoHubungan,
  });

  final String nama;
  final String jamMinumDefault; // "07:00"
  final bool fotoBuktiAktif;
  final String? pmoNama;
  final String? pmoHubungan;
  final List<Resep> resep;
  final bool consentDisetujui;
  final String versiConsent;

  factory Profil.fromJson(Map<String, dynamic> json) {
    final pmo = json['pmo'] as Map<String, dynamic>?;
    final daftarResep = (json['resep'] as List<dynamic>? ?? [])
        .map((e) => Resep.fromJson(e as Map<String, dynamic>))
        .toList();

    return Profil(
      nama: json['nama'] as String,
      jamMinumDefault: json['jam_minum_default'] as String,
      fotoBuktiAktif: json['foto_bukti_aktif'] as bool? ?? false,
      pmoNama: pmo?['nama'] as String?,
      pmoHubungan: pmo?['hubungan'] as String?,
      resep: daftarResep,
      consentDisetujui: json['consent_disetujui'] as bool? ?? false,
      versiConsent: json['versi_consent'] as String? ?? '1.0',
    );
  }
}
