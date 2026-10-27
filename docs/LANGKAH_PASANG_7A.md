# Batch 7A: Fondasi aplikasi Flutter (data tiruan)

Tujuan: aplikasi sudah bisa dijalankan dan diklik dari awal sampai akhir (aktivasi, persetujuan, beranda,
"Sudah minum", riwayat) memakai **data tiruan**, tanpa backend. Setelah 7A lolos, temanmu bisa mulai
menyempurnakan tampilan sementara kamu lanjut ke API (7B).

## 0. Prasyarat

1. Flutter SDK terpasang (ikuti panduan resmi di flutter.dev untuk sistem operasimu).
2. Android Studio terpasang **hanya untuk SDK dan emulator**. Setelah itu:
   ```bash
   flutter doctor
   flutter doctor --android-licenses
   ```
   Bagian "Android toolchain" tidak boleh bertanda silang.
3. VS Code dengan ekstensi **Flutter** dan **Dart**.
4. HP Android fisik: aktifkan Opsi Pengembang dan Debugging USB, lalu cek `flutter devices`.

## 1. Buat proyek (repositori terpisah dari backend)

```bash
flutter create --org id.kkn.rsud --platforms=android alarm_obat
cd alarm_obat
```

Catatan: `--org` + nama proyek menjadi application id (`id.kkn.rsud.alarm_obat`). Sebaiknya putuskan
sekarang, karena mengubahnya belakangan merepotkan. Ganti `id.kkn.rsud` bila perlu.

## 2. Pasang paket

```bash
flutter pub add provider intl
```

## 3. Salin file

- Hapus isi folder `lib/` bawaan (`main.dart` contoh counter).
- Hapus `test/widget_test.dart` jika ada (merujuk ke aplikasi counter yang sudah tidak ada).
- Salin folder `lib/` dan `docs/` dari paket ini ke akar proyek.

## 4. Nama aplikasi di HP

Buka `android/app/src/main/AndroidManifest.xml`, ubah `android:label` menjadi `Pengingat Obat`
(netral, tanpa kata TBC).

## 5. Cek dan jalankan

```bash
flutter analyze
flutter run
```

`flutter analyze` harus berakhir dengan `No issues found!`. Bila ada pesan, kirim apa adanya.

## 6. Checkpoint 7A

1. `flutter doctor`: toolchain Android lengkap.
2. `flutter analyze`: tidak ada masalah.
3. Aplikasi terbuka di HP/emulator dan menampilkan layar **aktivasi**.
4. Ketik kode salah (misalnya `ABC`) lalu **Aktifkan**: muncul pesan merah "Kode tidak valid...".
5. Ketik `ABCD-EFGH` lalu **Aktifkan**: masuk layar **Persetujuan**.
6. Tombol **Lanjut** mati sebelum kotak "Saya mengerti dan setuju" dicentang.
7. Setelah lanjut, **Beranda** menampilkan: nama, tanggal Indonesia, kartu "Obat berikutnya 07:00",
   tombol **SUDAH MINUM**, kartu obat, pendamping (PMO), dan jadwal hari ini.
8. Tekan **SUDAH MINUM**: kartu hari ini menjadi "Sudah minum", kartu berikutnya berubah menjadi
   "Semua obat hari ini sudah diminum", dan tombol mati.
9. **Riwayat minum obat** menampilkan hari-hari sebelumnya, termasuk satu hari "Belum tercatat" dan
   catatan hari ini.
10. **Agar alarm selalu berbunyi** menampilkan 5 langkah panduan.
11. Menu titik tiga > **Keluar / ganti HP**: kembali ke layar aktivasi.
12. **Uji huruf terbesar:** di HP, Pengaturan > Tampilan > Ukuran huruf > terbesar. Tidak boleh ada teks
    terpotong atau garis kuning-hitam "overflow" di layar mana pun.
13. Tarik layar beranda ke bawah (refresh): tidak error.

Catatan: data tiruan kembali ke awal setiap aplikasi dimulai ulang (hot restart). Itu normal.

## 7. Titik simpan

```bash
git init
git add -A
git commit -m "7A: fondasi Flutter dengan data tiruan"
```

Buat repositori GitHub **terpisah** (misalnya `alarm-tbc-mobile`, Private), lalu hubungkan dan push.
Jangan pernah meng-commit keystore (`*.jks`, `*.keystore`) atau `key.properties`.
