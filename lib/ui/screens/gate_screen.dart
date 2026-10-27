import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/app_state.dart';
import 'aktivasi_screen.dart';
import 'beranda_screen.dart';
import 'consent_screen.dart';

/// Memilih layar sesuai keadaan aplikasi: memuat, belum aktif, perlu consent, siap.
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
    }
  }
}
