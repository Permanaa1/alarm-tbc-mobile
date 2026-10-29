import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../logic/app_provider.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = true;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.argonHeaderGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cyanLight.withAlpha(35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PELINDUNGAN DATA PRIBADI (UU No. 27/2022)',
                          style: TextStyle(
                            color: AppColors.cyanLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Persetujuan Privasi & Layanan Pengingat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 145, 20, 32),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppArgonDecoration.elevatedCard(radius: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _PrivacyPoint(
                            icon: Icons.notifications_paused_rounded,
                            color: AppColors.tealPrimary,
                            title: 'Notifikasi Netral & Bebas Stigma',
                            subtitle:
                                'Pesan pengingat di layar HP hanya menampilkan teks umum "Waktunya minum obat" demi menjaga privasi Anda.',
                          ),
                          const SizedBox(height: 16),
                          const _PrivacyPoint(
                            icon: Icons.alarm_on_rounded,
                            color: AppColors.blueRoyal,
                            title: 'Jadwal Sesuai Resep Petugas Medis',
                            subtitle:
                                'Aplikasi menampilkan jadwal resmi dari rumah sakit dan tetap berbunyi meskipun HP sedang tanpa kuota internet.',
                          ),
                          const SizedBox(height: 16),
                          const _PrivacyPoint(
                            icon: Icons.lock_outline_rounded,
                            color: AppColors.blueMedium,
                            title: 'Kerahasiaan Riwayat Kepatuhan',
                            subtitle:
                                'Catatan konfirmasi minum obat hanya diakses oleh petugas resmi RSUD untuk mendukung keberhasilan pengobatan Anda.',
                          ),
                          const SizedBox(height: 22),
                          InkWell(
                            onTap: () => setState(() => _agreed = !_agreed),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _agreed
                                    ? AppColors.tealPrimary.withAlpha(20)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _agreed
                                      ? AppColors.tealPrimary
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _agreed,
                                    activeColor: AppColors.tealPrimary,
                                    onChanged: (v) =>
                                        setState(() => _agreed = v ?? false),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Saya memahami dan menyetujui penggunaan data pengingat obat sesuai ketentuan layanan RSUD.',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            onPressed: (!_agreed || app.isLoading)
                                ? null
                                : () => context
                                      .read<AppProvider>()
                                      .acceptConsent(),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('SETUJU & MASUK KE BERANDA'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: color.withAlpha(24),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}