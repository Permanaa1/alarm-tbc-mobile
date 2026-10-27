import 'package:flutter/material.dart';

/// Tombol utama berukuran besar. Bentuk dan ukuran diatur di AppTheme.
class TombolBesar extends StatelessWidget {
  const TombolBesar({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.sedangProses = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool sedangProses;

  @override
  Widget build(BuildContext context) {
    final Widget isi = sedangProses
        ? const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 30),
                const SizedBox(width: 12),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    return FilledButton(
      onPressed: sedangProses ? null : onPressed,
      child: isi,
    );
  }
}
