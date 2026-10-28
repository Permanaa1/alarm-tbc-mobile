import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/app_state.dart';
import '../widgets/tombol_besar.dart';
import 'aktivasi_screen.dart';
import 'beranda_screen.dart';
import 'consent_screen.dart';

/// Memilih layar sesuai keadaan aplikasi.
class GateScreen extends StatelessWidget {
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AppState, StatusApp>((s) => s.status);

    switch (status) {
      case StatusApp.memuat:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case StatusApp.belumAktif:
        return const AktivasiScreen();
      case StatusApp.perluConsent:
        return const ConsentScreen();
      case StatusApp.siap:
        return const BerandaScreen();
      case StatusApp.gagalMuat:
        return const _GagalMuat();
    }
  }
}

/// Tampil bila data tidak bisa dimuat (misalnya tidak ada koneksi) padahal HP sudah aktif.
class _GagalMuat extends StatelessWidget {
  const _GagalMuat();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final pesan = context.select<AppState, String?>((s) => s.pesanError);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.cloud_off, size: 72, color: tema.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                pesan ?? 'Data belum bisa dimuat.',
                textAlign: TextAlign.center,
                style: tema.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TombolBesar(
                label: 'Coba lagi',
                icon: Icons.refresh,
                onPressed: () => context.read<AppState>().ulangi(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
