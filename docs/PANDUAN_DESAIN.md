# Panduan untuk penyempurna tampilan

Aplikasi ini dipakai pasien TBC dan pendampingnya, **umumnya orang tua**. Prioritas: jelas, besar, sederhana.

## Menjalankan aplikasi

```bash
flutter pub get
flutter run
```

Data yang tampil masih **tiruan**, jadi tidak perlu server. Kode uji di layar aktivasi: `ABCD-EFGH`.

## Boleh diubah

| Lokasi | Isinya |
|---|---|
| `lib/core/app_theme.dart` | Warna, ukuran huruf, bentuk tombol. **Mulai dari sini.** |
| `lib/ui/screens/` | Tata letak tiap layar |
| `lib/ui/widgets/` | Komponen yang dipakai ulang (tombol besar, kartu jadwal) |
| `assets/` (buat bila perlu) | Gambar, ikon, font |

## Jangan diubah tanpa bicara dengan pengembang

- `lib/data/` dan `lib/logic/` (data, API, alarm, sinkronisasi).
- `pubspec.yaml` (kecuali menambah aset; kabari pengembang agar tidak bentrok).
- Nama method yang dipanggil layar, misalnya `context.read<AppState>().aktivasi(...)`. Tampilan boleh
  berubah total, tetapi pemanggilan fungsinya jangan dihapus.

## Layar yang ada

| Layar | File |
|---|---|
| Penentu layar awal | `gate_screen.dart` |
| Aktivasi (kode petugas) | `aktivasi_screen.dart` |
| Persetujuan (consent) | `consent_screen.dart` |
| Beranda | `beranda_screen.dart` |
| Riwayat | `riwayat_screen.dart` |
| Panduan agar alarm berbunyi | `panduan_izin_screen.dart` |

## Pedoman desain untuk pengguna lansia

- Satu tindakan utama per layar. Tombol "SUDAH MINUM" harus yang paling menonjol di beranda.
- Huruf besar dan kontras tinggi. Tombol minimal setinggi 56 dp.
- Bahasa sehari-hari, kalimat pendek. Ikon selalu disertai tulisan.
- Warna merah hanya untuk kesalahan. Jangan memakai merah untuk hal biasa.
- Nama aplikasi dan teks yang muncul di notifikasi **netral**. Jangan menulis kata "TBC" di tempat
  yang terlihat orang lain (layar kunci, ikon, nama aplikasi).
- Uji dengan ukuran huruf sistem terbesar (Pengaturan > Tampilan > Ukuran huruf). Tidak boleh ada
  teks terpotong atau tanda "overflow".
- Jangan menambahkan animasi yang ramai atau menu bersarang.

## Alur kerja Git

- `main`: hanya yang sudah lolos uji. `develop`: pekerjaan berjalan.
- Buat cabang sendiri untuk desain, misalnya `ui/beranda` atau `ui/tema`, lalu ajukan *pull request*
  ke `develop`.
- Commit kecil dan sering, dengan pesan yang jelas.
- Sebelum mengajukan: `flutter analyze` harus bersih.

## Menambah gambar atau font

1. Taruh file di `assets/images/` atau `assets/fonts/`.
2. Beri tahu pengembang agar didaftarkan di `pubspec.yaml` (satu orang saja yang mengedit file ini).
