import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../data/models/jadwal_item.dart';
import '../../logic/app_provider.dart';
import 'battery_guide_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _showAlarmSimulationSheet(
    BuildContext context,
    AppProvider app,
    JadwalItem? schedule,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.tealPrimary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 38,
                color: AppColors.tealPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Waktunya Minum Obat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Jadwal Pukul ${schedule?.time ?? '07:00'} • ${app.prescriptionLabel}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (schedule != null) ...[
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  app.recordDoseStatus(schedule, 'diminum');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Alhamdulillah! Konfirmasi minum obat berhasil dicatat.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('SUDAH MINUM SEKARANG'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  app.recordDoseStatus(schedule, 'ditunda');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengingat ditunda 10 menit.'),
                    ),
                  );
                },
                icon: const Icon(Icons.snooze_rounded),
                label: const Text('Tunda 10 Menit'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardTab(
            onSimulateAlarm: (app, schedule) =>
                _showAlarmSimulationSheet(context, app, schedule),
            onOpenTab: (idx) => setState(() => _selectedIndex = idx),
          ),
          const HistoryScreen(embedded: true),
          const BatteryGuideScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.navyDark),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(
              Icons.history_toggle_off_rounded,
              color: AppColors.navyDark,
            ),
            label: 'Riwayat 30 Hari',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(
              Icons.shield_rounded,
              color: AppColors.navyDark,
            ),
            label: 'Panduan Pengingat',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.onSimulateAlarm,
    required this.onOpenTab,
  });

  final void Function(AppProvider, JadwalItem?) onSimulateAlarm;
  final void Function(int) onOpenTab;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final todaySchedule = app.todayDrinkSchedule;
    final currentStatus =
        todaySchedule != null ? app.scheduleStatus(todaySchedule) : null;
    final isTaken = currentStatus == 'diminum';
    final isSnoozed = currentStatus == 'ditunda';

    return RefreshIndicator(
      onRefresh: app.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Stack(
          children: [
            // Argon Top Gradient Background
            Container(
              height: 255,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.argonHeaderGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Bar Argon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(28),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.medical_services_rounded,
                                      color: AppColors.cyanLight,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Pengingat Obat Harian',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Pill Status Sinkronisasi
                            InkWell(
                              onTap: app.syncNow,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: app.pendingSync == 0
                                      ? AppColors.tealPrimary.withAlpha(60)
                                      : AppColors.warning.withAlpha(60),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: app.pendingSync == 0
                                        ? AppColors.cyanLight.withAlpha(140)
                                        : AppColors.warning,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      app.pendingSync == 0
                                          ? Icons.cloud_done_rounded
                                          : Icons.cloud_upload_rounded,
                                      size: 14,
                                      color: AppColors.cyanLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      app.pendingSync == 0
                                          ? 'Tersinkron'
                                          : '${app.pendingSync} Antrean',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Sapaan Pasien & Identitas PMO
                        Text(
                          'Halo, ${app.patientName}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 15,
                              color: AppColors.cyanLight,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'No. RM ${app.rmNumber}  •  ${app.pmoLabel}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFD9E6FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // 1. HERO CARD ARGON: JADWAL MINUM HARI INI (Paling Atas)
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: AppArgonDecoration.elevatedCard(
                            borderColor: isTaken
                                ? AppColors.success
                                : AppColors.tealBright,
                            radius: 22,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.tealPrimary
                                                .withAlpha(25),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.alarm_rounded,
                                            color: AppColors.tealPrimary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'JADWAL MINUM HARI INI',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.7,
                                              color: AppColors.blueRoyal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusPill(
                                    isTaken: isTaken,
                                    isSnoozed: isSnoozed,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Kotak Jam Ukuran Besar Ramah Lansia
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cyanLight.withAlpha(28),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.tealBright.withAlpha(90),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            todaySchedule?.time ?? '07:00',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 44,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.navyDark,
                                              height: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            todaySchedule != null
                                                ? app.scheduleNotes(todaySchedule)
                                                : app.prescriptionLabel,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.blueRoyal,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        todaySchedule?.date ?? 'Hari Ini',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navyDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Tombol Utama SUDAH MINUM (Ekstra Besar)
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: isTaken
                                      ? AppColors.success
                                      : AppColors.tealPrimary,
                                  minimumSize: const Size.fromHeight(58),
                                ),
                                onPressed: todaySchedule == null
                                    ? null
                                    : () {
                                        app.recordDoseStatus(
                                          todaySchedule,
                                          'diminum',
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tercatat: Obat hari ini sudah diminum.',
                                            ),
                                          ),
                                        );
                                      },
                                icon: Icon(
                                  isTaken
                                      ? Icons.verified_rounded
                                      : Icons.check_circle_rounded,
                                  size: 24,
                                ),
                                label: Text(
                                  isTaken
                                      ? 'TERCATAT SUDAH MINUM'
                                      : 'SUDAH MINUM OBAT',
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Tombol Tunda 10 Menit
                              OutlinedButton.icon(
                                onPressed: todaySchedule == null
                                    ? null
                                    : () {
                                        app.recordDoseStatus(
                                          todaySchedule,
                                          'ditunda',
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Pengingat ditunda 10 menit.',
                                            ),
                                          ),
                                        );
                                      },
                                icon: const Icon(Icons.snooze_rounded),
                                label: const Text('Tunda 10 Menit'),
                              ),
                              const SizedBox(height: 6),

                              // Simulasi Bunyi Pengingat
                              TextButton.icon(
                                onPressed: () =>
                                    onSimulateAlarm(app, todaySchedule),
                                icon: const Icon(
                                  Icons.volume_up_rounded,
                                  size: 18,
                                  color: AppColors.blueMedium,
                                ),
                                label: const Text(
                                  'Simulasikan tampilan saat alarm berbunyi',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blueMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. KARTU INFORMASI RESEP AKTIF
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: AppArgonDecoration.elevatedCard(),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.blueRoyal.withAlpha(22),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.assignment_outlined,
                                  color: AppColors.blueRoyal,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'INFORMASI RESEP DOKTER',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      app.prescriptionLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Dosis mengikuti petunjuk petugas RSUD',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 3. GRID 2 KOLOM: JADWAL KONTROL & AMBIL OBAT
                        Row(
                          children: [
                            Expanded(
                              child: _AgendaMiniCard(
                                icon: Icons.event_available_rounded,
                                accentColor: AppColors.blueMedium,
                                label: 'JADWAL KONTROL',
                                dateText: app.nextControlDate,
                                subtitle: 'Poliklinik RSUD',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AgendaMiniCard(
                                icon: Icons.inventory_2_outlined,
                                accentColor: AppColors.tealPrimary,
                                label: 'AMBIL OBAT',
                                dateText: app.nextRefillDate,
                                subtitle: 'Instalasi Farmasi',
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isTaken, required this.isSnoozed});

  final bool isTaken;
  final bool isSnoozed;

  @override
  Widget build(BuildContext context) {
    final Color bg = isTaken
        ? AppColors.success.withAlpha(28)
        : isSnoozed
        ? AppColors.warning.withAlpha(28)
        : AppColors.blueRoyal.withAlpha(22);

    final Color fg = isTaken
        ? const Color(0xFF16794B)
        : isSnoozed
        ? const Color(0xFFC84628)
        : AppColors.blueRoyal;

    final String text = isTaken
        ? 'Sudah Diminum'
        : isSnoozed
        ? 'Ditunda 10m'
        : 'Belum Konfirmasi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _AgendaMiniCard extends StatelessWidget {
  const _AgendaMiniCard({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.dateText,
    required this.subtitle,
  });

  final IconData icon;
  final Color accentColor;
  final String label;
  final String dateText;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppArgonDecoration.elevatedCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(24),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}