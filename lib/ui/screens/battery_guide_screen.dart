import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';

class BatteryGuideScreen extends StatelessWidget {
  const BatteryGuideScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Panduan Pengaturan Pengingat'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.argonHeaderGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyanLight.withAlpha(35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.battery_saver_rounded,
                        color: AppColors.cyanLight,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agar Alarm Selalu Tepat Waktu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Aktifkan pengaturan berikut agar pengingat tetap berbunyi meskipun layar HP mati.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD9E6FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _GuideCard(
                step: '1',
                brand: 'Izin Notifikasi & Alarm Tepat Waktu (Android 13+)',
                color: AppColors.tealPrimary,
                steps: [
                  'Buka Pengaturan (Settings) > Aplikasi > Pengingat Obat Harian.',
                  'Pilih menu Notifikasi lalu aktifkan "Izinkan Notifikasi".',
                  'Pilih menu "Alarm & Pengingat" lalu pastikan saklar dalam posisi Aktif.',
                ],
              ),
              const SizedBox(height: 12),
              const _GuideCard(
                step: '2',
                brand: 'HP Xiaomi / Redmi / POCO (MIUI & HyperOS)',
                color: AppColors.blueRoyal,
                steps: [
                  'Buka Info Aplikasi > aktifkan opsi "Mulai Otomatis" (Autostart).',
                  'Pilih menu "Penghemat Baterai" lalu ubah menjadi "Tanpa Pembatasan".',
                ],
              ),
              const SizedBox(height: 12),
              const _GuideCard(
                step: '3',
                brand: 'HP Oppo / Realme (ColorOS) & Vivo (FuntouchOS)',
                color: AppColors.blueMedium,
                steps: [
                  'Buka Info Aplikasi > Penggunaan Baterai.',
                  'Aktifkan "Izinkan Aktivitas Latar Belakang" dan "Izinkan Mulai Otomatis".',
                ],
              ),
              const SizedBox(height: 12),
              const _GuideCard(
                step: '4',
                brand: 'HP Samsung (One UI)',
                color: AppColors.navyDark,
                steps: [
                  'Buka Pengaturan Aplikasi > pilih bagian Baterai.',
                  'Pilih opsi "Tidak Dibatasi" (Unrestricted) agar alarm tidak ditidurkan sistem.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.step,
    required this.brand,
    required this.color,
    required this.steps,
  });

  final String step;
  final String brand;
  final Color color;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppArgonDecoration.elevatedCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  brand,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.tealPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}