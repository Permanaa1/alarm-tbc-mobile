import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/constants.dart';
import 'data/api/api_client.dart';
import 'data/api/token_store.dart';
import 'data/repositories/api_pasien_repository.dart';
import 'data/repositories/mock_pasien_repository.dart';
import 'data/repositories/pasien_repository.dart';
import 'logic/app_state.dart';

PasienRepository _buatRepository() {
  if (Konstanta.pakaiMock) {
    return MockPasienRepository();
  }
  final token = TokenStore();
  return ApiPasienRepository(ApiClient(token), token);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(_buatRepository())..mulai(),
      child: const AlarmObatApp(),
    ),
  );
}
