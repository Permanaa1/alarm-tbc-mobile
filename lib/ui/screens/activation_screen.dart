import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../logic/app_provider.dart';

class _ActivationCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final clamped = raw.length > 8 ? raw.substring(0, 8) : raw;
    final buffer = StringBuffer();
    for (int i = 0; i < clamped.length; i++) {
      if (i == 4) buffer.write('-');
      buffer.write(clamped[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'ABCD-EFGH',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final code = _controller.text.trim();
    if (code.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 8 karakter kode aktivasi dari petugas.'),
        ),
      );
      return;
    }
    await context.read<AppProvider>().activateWithCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Argon Curved Gradient Header
            Container(
              height: 310,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.argonHeaderGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppColors.cyanLight.withAlpha(35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.cyanLight.withAlpha(110),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.medication_liquid_rounded,
                          size: 36,
                          color: AppColors.cyanLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pengingat Obat Harian',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'RSUD Dr. R. Soedjati Soemodiardjo',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.cyanLight,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Overlapping Argon Card
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 200, 20, 32),
                    child: Container(
                      padding: const EdgeInsets.all(26),
                      decoration: AppArgonDecoration.elevatedCard(radius: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.tealPrimary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: AppColors.tealPrimary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Aktivasi Perangkat Pasien',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                                    const Text(
                                      'Masukkan 8 karakter kode dari petugas',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _controller,
                            inputFormatters: [_ActivationCodeFormatter()],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.0,
                              color: AppColors.navyDark,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'KODE AKTIVASI',
                              hintText: 'ABCD-EFGH',
                              prefixIcon: Icon(
                                Icons.vpn_key_rounded,
                                color: AppColors.blueRoyal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Chip Kode Simulasi
                          Center(
                            child: InkWell(
                              onTap: () => _controller.text = 'ABCD-EFGH',
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.blueRoyal.withAlpha(18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 15,
                                      color: AppColors.blueRoyal,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Kode simulasi uji coba: ABCD-EFGH',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.blueRoyal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if (app.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.danger.withAlpha(80),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.danger,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      app.errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: app.isLoading
                                ? null
                                : () => _submit(context),
                            icon: const Icon(Icons.login_rounded),
                            label: Text(
                              app.isLoading
                                  ? 'MEMVERIFIKASI...'
                                  : 'AKTIFKAN & LANJUTKAN',
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              _controller.text = 'ABCD-EFGH';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Simulasi QR berhasil mengisi kode ABCD-EFGH',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: const Text('Pindai QR Kartu Pasien'),
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