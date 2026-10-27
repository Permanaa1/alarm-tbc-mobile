import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/models/jadwal_item.dart';
import '../../logic/app_state.dart';
import '../widgets/kartu_jadwal.dart';
import '../widgets/tombol_besar.dart';
import 'panduan_izin_screen.dart';
import 'riwayat_screen.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  Future<void> _konfirmasiKeluar(BuildContext context) async {
    final state = context.read<AppState>();
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari aplikasi?'),
        content: const Text('Anda perlu kode baru dari petugas untuk masuk lagi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ya == true) {
      await state.keluar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tema = Theme.of(context);
    final profil = state.profil;
    final berikutnya = state.berikutnya;
    final pmoNama = profil?.pmoNama;
    final pmoHubungan = profil?.pmoHubungan;
    final tanggalTeks =
        DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text(Konstanta.namaApp),
        actions: [
          PopupMenuButton<String>(
            onSelected: (nilai) {
              if (nilai == 'keluar') _konfirmasiKeluar(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'keluar', child: Text('Keluar / ganti HP')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<AppState>().segarkan(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text('Halo, ${profil?.nama ?? ''}',
                  style: tema.textTheme.headlineSmall),
              Text(tanggalTeks, style: tema.textTheme.bodyLarge),
              const SizedBox(height: 16),
              if (state.pesanError != null) ...[
                Text(
                  state.pesanError!,
                  style: TextStyle(color: tema.colorScheme.error, fontSize: 18),
                ),
                const SizedBox(height: 8),
              ],
              _KartuBerikutnya(
                berikutnya: berikutnya,
                adaJadwalHariIni: state.jadwalHariIni.isNotEmpty,
              ),
              const SizedBox(height: 16),
              TombolBesar(
                label: 'SUDAH MINUM',
                icon: Icons.check_circle_outline,
                sedangProses: state.sedangProses,
                onPressed: berikutnya == null
                    ? null
                    : () => context.read<AppState>().tandaiSudahMinum(berikutnya),
              ),
              const SizedBox(height: 24),
              if (profil != null && profil.resep.isNotEmpty) ...[
                Text('Obat Anda', style: tema.textTheme.titleLarge),
                for (final r in profil.resep)
                  Card(
                    child: ListTile(
                      title: Text(r.namaObat),
                      subtitle: Text(r.dosisTeks),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              if (pmoNama != null) ...[
                Text(
                  pmoHubungan != null
                      ? 'Pendamping (PMO): $pmoNama ($pmoHubungan)'
                      : 'Pendamping (PMO): $pmoNama',
                  style: tema.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
              ],
              Text('Jadwal hari ini', style: tema.textTheme.titleLarge),
              for (final j in state.jadwalHariIni) KartuJadwal(item: j),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const RiwayatScreen()),
                ),
                child: const Text('Riwayat minum obat'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const PanduanIzinScreen()),
                ),
                child: const Text('Agar alarm selalu berbunyi'),
              ),
              const SizedBox(height: 24),
              Text(
                'Aplikasi ini hanya pengingat. Ikuti aturan minum obat dari dokter atau petugas.',
                style: tema.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuBerikutnya extends StatelessWidget {
  const _KartuBerikutnya({
    required this.berikutnya,
    required this.adaJadwalHariIni,
  });

  final JadwalItem? berikutnya;
  final bool adaJadwalHariIni;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: berikutnya != null
            ? Column(
                children: [
                  Text('Obat berikutnya', style: tema.textTheme.titleMedium),
                  Text(
                    berikutnya!.jam,
                    style: tema.textTheme.displayMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (berikutnya!.keterangan != null)
                    Text(berikutnya!.keterangan!,
                        style: tema.textTheme.bodyLarge),
                ],
              )
            : Column(
                children: [
                  Icon(Icons.check_circle,
                      size: 48, color: tema.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    adaJadwalHariIni
                        ? 'Semua obat hari ini sudah diminum'
                        : 'Tidak ada jadwal hari ini',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleLarge,
                  ),
                ],
              ),
      ),
    );
  }
}
