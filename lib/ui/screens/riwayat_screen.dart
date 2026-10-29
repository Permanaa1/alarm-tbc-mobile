import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/app_state.dart';
import '../widgets/kartu_jadwal.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final riwayat = state.riwayat;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat minum obat')),
      body: SafeArea(
        child: riwayat.isEmpty
            ? Center(
                child: Text('Belum ada riwayat.',
                    style: tema.textTheme.titleLarge),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: riwayat.length,
                itemBuilder: (_, i) => KartuJadwal(
                  item: riwayat[i],
                  tampilkanTanggal: true,
                  belumTerkirim: state.idBelumTerkirim.contains(riwayat[i].id),
                ),
              ),
      ),
    );
  }
}
