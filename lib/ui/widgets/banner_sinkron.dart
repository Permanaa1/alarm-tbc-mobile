import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../logic/app_state.dart';

/// Pemberitahuan keadaan offline dan catatan yang belum terkirim.
/// Tidak tampil sama sekali bila semuanya normal.
class BannerSinkron extends StatelessWidget {
  const BannerSinkron({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.jumlahAntrean == 0 && !state.memakaiDataLokal) {
      return const SizedBox.shrink();
    }

    final tema = Theme.of(context);
    final pesan = <String>[];

    if (state.jumlahAntrean > 0) {
      pesan.add(
        '${state.jumlahAntrean} catatan minum menunggu dikirim ke server. Data aman tersimpan di HP.',
      );
    }

    if (state.memakaiDataLokal) {
      final t = state.terakhirSinkron;
      pesan.add(
        t == null
            ? 'Tidak ada koneksi. Menampilkan data yang tersimpan.'
            : 'Tidak ada koneksi. Data terakhir diperbarui ${DateFormat('d MMM HH:mm', 'id_ID').format(t)}.',
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: tema.colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cloud_off,
                      color: tema.colorScheme.onTertiaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pesan.join('\n'),
                      style: tema.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (state.jumlahAntrean > 0) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.read<AppState>().kirimSekarang(),
                  child: const Text('Kirim sekarang'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
