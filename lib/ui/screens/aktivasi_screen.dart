import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../logic/app_state.dart';
import '../widgets/tombol_besar.dart';

class AktivasiScreen extends StatefulWidget {
  const AktivasiScreen({super.key});

  @override
  State<AktivasiScreen> createState() => _AktivasiScreenState();
}

class _AktivasiScreenState extends State<AktivasiScreen> {
  final TextEditingController _kontrol = TextEditingController();

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    await context.read<AppState>().aktivasi(_kontrol.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.medication_outlined,
                  size: 72, color: tema.colorScheme.primary),
              const SizedBox(height: 16),
              Text(Konstanta.namaApp,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineMedium),
              const SizedBox(height: 32),
              Text('Masukkan kode dari petugas rumah sakit',
                  style: tema.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Kode ada di kartu yang diberikan petugas.',
                  style: tema.textTheme.bodyLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _kontrol,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                textAlign: TextAlign.center,
                style: tema.textTheme.headlineSmall,
                maxLength: 9,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ABCD-EFGH',
                  counterText: '',
                ),
                onSubmitted: (_) => _kirim(),
              ),
              if (state.pesanError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.pesanError!,
                    style: TextStyle(
                        color: tema.colorScheme.error, fontSize: 18),
                  ),
                ),
              const SizedBox(height: 16),
              TombolBesar(
                label: 'Aktifkan',
                icon: Icons.check_circle_outline,
                sedangProses: state.sedangProses,
                onPressed: _kirim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
