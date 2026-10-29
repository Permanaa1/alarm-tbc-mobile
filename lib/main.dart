import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/constants.dart';
import 'data/api/api_client.dart';
import 'data/api/pasien_api.dart';
import 'data/api/token_store.dart';
import 'data/local/lokal_store.dart';
import 'data/repositories/mock_pasien_repository.dart';
import 'data/repositories/pasien_repository.dart';
import 'data/repositories/sinkron_pasien_repository.dart';
import 'logic/app_provider.dart';
import 'ui/screens/activation_screen.dart';
import 'ui/screens/consent_screen.dart';
import 'ui/screens/home_screen.dart';

PasienRepository _buatRepository() {
  if (Konstanta.pakaiMock) {
    return MockPasienRepository();
  }
  final token = TokenStore();
  return SinkronPasienRepository(
    PasienApi(ApiClient(token)),
    PrefsLokalStore(),
    token,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(_buatRepository())..initialize(),
      child: const PatientApp(),
    ),
  );
}

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: Konstanta.namaApp,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const _AppEntry(),
  );
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) => Consumer<AppProvider>(
    builder: (context, app, _) {
      if (app.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!app.isActivated) return const ActivationScreen();
      if (!app.consentGranted) return const ConsentScreen();
      return const HomeScreen();
    },
  );
}
