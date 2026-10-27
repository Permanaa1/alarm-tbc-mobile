import 'package:flutter/material.dart';

/// SEMUA warna, ukuran huruf, dan bentuk tombol diatur di sini.
/// Penyempurna desain cukup mengubah file ini dan folder lib/ui/.
class AppTheme {
  static const Color warnaUtama = Color(0xFF1B7F79);

  static ThemeData terang() {
    final skema = ColorScheme.fromSeed(seedColor: warnaUtama);
    final dasar = ThemeData(colorScheme: skema, useMaterial3: true);
    final teksDasar = dasar.typography.black.merge(dasar.typography.englishLike);

    return dasar.copyWith(
      // Huruf dibesarkan untuk pengguna lansia
      textTheme: teksDasar.apply(fontSizeFactor: 1.15),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: skema.primary,
        foregroundColor: skema.onPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(72),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          textStyle: const TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}