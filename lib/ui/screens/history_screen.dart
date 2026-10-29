import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../logic/app_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final logs = app.history.reversed.toList();
    final takenCount = logs.where((l) => l.status == 'diminum').length;
    final snoozedCount = logs.where((l) => l.status == 'ditunda').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Riwayat Kepatuhan 30 Hari'),
        actions: [
          IconButton(
            tooltip: 'Sinkronkan ulang',
            onPressed: app.syncNow,
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Ringkasan Statistik Argon
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'SUDAH DIMINUM',
                      value: '$takenCount',
                      color: AppColors.tealPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'DITUNDA',
                      value: '$snoozedCount',
                      color: AppColors.blueRoyal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Catatan Konfirmasi Harian',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 12),
              if (logs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: AppArgonDecoration.elevatedCard(),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        size: 42,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada riwayat konfirmasi minum obat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...logs.map((log) {
                  final isTaken = log.status == 'diminum';
                  final badgeColor = isTaken
                      ? AppColors.tealPrimary
                      : AppColors.warning;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppArgonDecoration.elevatedCard(),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: badgeColor.withAlpha(24),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isTaken
                                  ? Icons.check_circle_rounded
                                  : Icons.snooze_rounded,
                              color: badgeColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal ${log.date}  •  ${log.time}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navyDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  log.synced
                                      ? 'Tersinkron ke server RSUD'
                                      : 'Menunggu sinkronisasi sinyal',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withAlpha(24),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isTaken ? 'Diminum' : 'Ditunda',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppArgonDecoration.elevatedCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}