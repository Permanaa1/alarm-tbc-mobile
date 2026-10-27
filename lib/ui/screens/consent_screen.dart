import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/app_state.dart';
import '../widgets/tombol_besar.dart';

// TODO: ganti dengan naskah resmi yang disetujui rumah sakit (versi 1.0).
const String _naskahSementara = '''
(NASKAH SEMENTARA. Teks resmi menunggu persetujuan rumah sakit.)

Aplikasi ini membantu mengingatkan Anda minum obat sesuai jadwal dari petugas.

Data yang digunakan: nama, jadwal minum obat, resep yang diisi petugas, dan catatan kapan Anda menekan "Sudah minum".

Data ini hanya dapat dilihat oleh petugas rumah sakit yang menangani Anda dan dijaga kerahasiaannya.

Aplikasi ini hanya pengingat. Ikuti selalu aturan minum obat dari dokter atau petugas. Jangan mengubah dosis sendiri.
''';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _setuju = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Persetujuan')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_naskahSementara, style: tema.textTheme.bodyLarge),
                ),
              ),
              if (state.pesanError != null)
                Text(
                  state.pesanError!,
                  style: TextStyle(color: tema.colorScheme.error, fontSize: 18),
                ),
              CheckboxListTile(
                value: _setuju,
                onChanged: (v) => setState(() => _setuju = v ?? false),
                title: const Text('Saya mengerti dan setuju',
                    style: TextStyle(fontSize: 20)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              TombolBesar(
                label: 'Lanjut',
                sedangProses: state.sedangProses,
                onPressed: _setuju
                    ? () => context.read<AppState>().setujuConsent()
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
