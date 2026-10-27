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
  });

  final JadwalItem item;
  final bool tampilkanTanggal;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final selesai = item.sudahMinum;
    final judul = tampilkanTanggal
        ? '${DateFormat('EEE, d MMM', 'id_ID').format(item.tanggal)} · ${item.jam}'
        : item.jam;

    return Card(
      child: ListTile(
        leading: Icon(
          selesai ? Icons.check_circle : Icons.schedule,
          size: 36,
          color: selesai ? tema.colorScheme.primary : tema.colorScheme.outline,
        ),
        title: Text(judul, style: tema.textTheme.titleLarge),
        subtitle: Text(labelStatus(item.status), style: tema.textTheme.bodyLarge),
      ),
    );
  }
}
