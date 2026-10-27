import 'package:flutter/material.dart';

class _Langkah {
  const _Langkah(this.judul, this.isi);
  final String judul;
  final String isi;
}

// Letak menu berbeda-beda tiap merek HP. Tombol pintas ke pengaturan menyusul di Batch 7D.
const List<_Langkah> _langkah = [
  _Langkah(
    '1. Izinkan notifikasi',
    'Saat aplikasi meminta izin menampilkan notifikasi, pilih "Izinkan".',
  ),
  _Langkah(
    '2. Izinkan alarm tepat waktu',
    'Buka Pengaturan > Aplikasi > Pengingat Obat > "Alarm & pengingat", lalu aktifkan.',
  ),
  _Langkah(
    '3. Matikan penghemat baterai untuk aplikasi ini',
    'Buka Pengaturan > Baterai > Pengingat Obat, lalu pilih "Tidak dibatasi".',
  ),
  _Langkah(
    '4. HP Xiaomi, Oppo, atau Vivo',
    'Aktifkan "Mulai otomatis" (Autostart) untuk aplikasi ini, dan kunci aplikasi di layar aplikasi terbaru.',
  ),
  _Langkah(
    '5. Jangan "paksa berhenti"',
    'Menghentikan paksa aplikasi dapat membuat alarm tidak berbunyi.',
  ),
];

class PanduanIzinScreen extends StatelessWidget {
  const PanduanIzinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Agar alarm berbunyi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Ikuti langkah berikut agar alarm obat selalu berbunyi tepat waktu.',
              style: tema.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            for (final l in _langkah)
              Card(
                child: ListTile(
                  title: Text(l.judul, style: tema.textTheme.titleMedium),
                  subtitle: Text(l.isi, style: tema.textTheme.bodyLarge),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Menu bisa berbeda tiap merek HP. Tanyakan ke petugas bila bingung.',
              style: tema.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
