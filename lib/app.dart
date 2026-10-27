import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/constants.dart';
import 'ui/screens/gate_screen.dart';

class AlarmObatApp extends StatelessWidget {
  const AlarmObatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Konstanta.namaApp,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.terang(),
      home: const GateScreen(),
    );
  }
}
