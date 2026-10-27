import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/mock_pasien_repository.dart';
import 'data/repositories/pasien_repository.dart';
import 'logic/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  // Batch 7A: data tiruan. Batch 7B: ganti dengan repository yang memanggil API asli.
  final PasienRepository repo = MockPasienRepository();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(repo)..mulai(),
      child: const AlarmObatApp(),
    ),
  );
}
