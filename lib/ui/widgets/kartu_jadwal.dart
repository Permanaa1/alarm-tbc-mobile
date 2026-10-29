import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/jadwal_item.dart';

String labelStatus(String? status) {
  switch (status) {
    case 'diminum':
      return 'Sudah minum';
    case 'ditunda':
      return 'Ditunda';
    case 'terlewat':
      return 'Terlewat';
    case 'belum_terkonfirmasi':
      return 'Belum tercatat';
    default:
      return 'Menunggu';
  }
}

class KartuJadwal extends StatelessWidget {
  const KartuJadwal({
    super.key,
    required this.item,
    this.tampilkanTanggal = false,
    this.belumTerkirim = false,
  });

  final JadwalItem item;
  final bool tampilkanTanggal;

  /// true bila konfirmasi minum sudah disimpan di HP tetapi belum sampai ke server.
  final bool belumTerkirim;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final selesai = item.sudahMinum;
    final judul = tampilkanTanggal
        ? '${DateFormat('EEE, d MMM', 'id_ID').format(item.tanggal)} · ${item.jam}'
        : item.jam;
    final status = belumTerkirim
        ? '${labelStatus(item.status)} · menunggu dikirim'
        : labelStatus(item.status);

    return Card(
      child: ListTile(
        leading: Icon(
          selesai ? Icons.check_circle : Icons.schedule,
          size: 36,
          color: selesai ? tema.colorScheme.primary : tema.colorScheme.outline,
        ),
        title: Text(judul, style: tema.textTheme.titleLarge),
        subtitle: Text(status, style: tema.textTheme.bodyLarge),
      ),
    );
  }
}
