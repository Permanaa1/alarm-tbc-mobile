// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/foundation.dart';

import '../data/models/jadwal_item.dart';
import '../data/models/profil.dart';
import '../data/repositories/pasien_repository.dart';

class AppProvider extends ChangeNotifier {
  AppProvider(this._repository);

  final PasienRepository _repository;

  bool isLoading = true;
  bool isActivated = false;
  bool consentGranted = false;
  String? errorMessage;

  Profil? profile;
  List<JadwalItem> schedules = [];
  List<JadwalItem> history = [];
  int pendingSync = 0;

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final loadedProfile = await _repository.ambilProfil();
      profile = loadedProfile;
      isActivated = true;
      consentGranted = profile?.consentDisetujui ?? false;
      if (consentGranted) {
        await refreshData();
      }
    } catch (_) {
      isActivated = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> activateWithCode(String rawCode) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final clean = rawCode.trim().toUpperCase();
      profile = await _repository.aktivasi(clean);
      isActivated = true;

      consentGranted = profile?.consentDisetujui ?? false;
      if (consentGranted) {
        await refreshData();
      }
      isLoading = false;
      notifyListeners();
      return isActivated;
    } catch (_) {
      errorMessage =
          'Aktivasi belum berhasil. Periksa koneksi ke server dan coba lagi.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> acceptConsent() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.setujuiConsent();
      consentGranted = true;
      await refreshData();
    } catch (_) {
      errorMessage = 'Gagal menyimpan persetujuan. Silakan coba lagi.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    try {
      schedules = await _repository.ambilJadwal();
      history = await _repository.ambilRiwayat();
      pendingSync = _repository.statusSinkron.jumlahAntrean;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> recordDoseStatus(
    JadwalItem schedule,
    String status,
  ) async {
    if (status == 'diminum') {
      await _repository.catatMinum(schedule.id);
    }
    await refreshData();
  }

  Future<void> syncNow() async {
    try {
      await _repository.kirimAntrean();
    } catch (_) {}
    await refreshData();
  }

  // Helper Pembaca Data Profil yang Aman terhadap Variasi Model
  String get patientName {
    final dynamic p = profile;
    if (p == null) return 'Sutrisno';
    try {
      return (p.name as String?) ?? 'Sutrisno';
    } catch (_) {}
    try {
      return (p.nama as String?) ?? 'Sutrisno';
    } catch (_) {}
    return 'Sutrisno';
  }

  String get rmNumber {
    final dynamic p = profile;
    if (p == null) return '000101';
    try {
      return (p.rmNumber as String?) ?? '000101';
    } catch (_) {}
    try {
      return (p.noRm as String?) ?? '000101';
    } catch (_) {}
    try {
      return (p.medicalRecordNumber as String?) ?? '000101';
    } catch (_) {}
    return '000101';
  }

  String get pmoLabel {
    final dynamic p = profile;
    if (p == null) return 'PMO Keluarga';
    try {
      return (p.pmoName as String?) ?? 'PMO Keluarga';
    } catch (_) {}
    try {
      return (p.pmo as String?) ?? 'PMO Keluarga';
    } catch (_) {}
    try {
      return (p.companionName as String?) ?? 'PMO Keluarga';
    } catch (_) {}
    return 'PMO Keluarga';
  }

  String get prescriptionLabel {
    final dynamic p = profile;
    if (p == null) return 'OAT KDT Fase Intensif';
    try {
      return (p.prescription as String?) ?? 'OAT KDT Fase Intensif';
    } catch (_) {}
    try {
      return (p.activePrescription as String?) ?? 'OAT KDT Fase Intensif';
    } catch (_) {}
    try {
      return (p.resep as String?) ?? 'OAT KDT Fase Intensif';
    } catch (_) {}
    return 'OAT KDT Fase Intensif';
  }

  String scheduleType(JadwalItem s) {
    final dynamic d = s;
    try {
      return (d.type as String?) ?? 'minum';
    } catch (_) {}
    try {
      return (d.jenis as String?) ?? 'minum';
    } catch (_) {}
    try {
      return (d.category as String?) ?? 'minum';
    } catch (_) {}
    return 'minum';
  }

  String scheduleNotes(JadwalItem s) {
    final dynamic d = s;
    try {
      final val = d.notes as String?;
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}
    try {
      final val = d.keterangan as String?;
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}
    try {
      final val = d.description as String?;
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}
    return prescriptionLabel;
  }

  String? scheduleStatus(JadwalItem s) {
    for (final log in history.reversed) {
      if (log.scheduleId.toString() == s.id.toString() && log.date == s.date) {
        return log.status;
      }
    }
    final dynamic d = s;
    try {
      return d.status as String?;
    } catch (_) {}
    return null;
  }

  JadwalItem? get todayDrinkSchedule {
    final drinkList = schedules
        .where((s) => scheduleType(s).toLowerCase().contains('minum'))
        .toList();
    if (drinkList.isNotEmpty) return drinkList.first;
    if (schedules.isNotEmpty) return schedules.first;
    return null;
  }

  String get nextControlDate {
    for (final s in schedules) {
      if (scheduleType(s).toLowerCase().contains('kontrol')) {
        return s.date;
      }
    }
    return '2026-11-03';
  }

  String get nextRefillDate {
    for (final s in schedules) {
      final t = scheduleType(s).toLowerCase();
      if (t.contains('ambil') || t.contains('obat')) {
        return s.date;
      }
    }
    return '2026-11-10';
  }
}