import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_preferences.dart';
import '../models/blood_center.dart';
import '../models/donation_record.dart';
import '../models/donor_profile.dart';

/// Exclusively uses Hive (`hive` + `hive_flutter`) for all local v1 persistence.
class HiveService {
  static const String profileBoxName = 'donor_profile';
  static const String donationsBoxName = 'donations';
  static const String bloodCentersBoxName = 'blood_centers';
  static const String preferencesBoxName = 'preferences';
  static const String metaBoxName = 'app_meta';

  static const String _profileKey = 'current_donor';
  static const String _preferencesKey = 'current_preferences';
  static const String _seededKey = 'initial_data_seeded';

  late Box<DonorProfile> _profileBox;
  late Box<DonationRecord> _donationsBox;
  late Box<BloodCenter> _bloodCentersBox;
  late Box<AppPreferences> _preferencesBox;
  late Box<bool> _metaBox;

  Future<void> init({String? customPath, String boxPrefix = ''}) async {
    if (customPath != null) {
      Hive.init(customPath);
    } else {
      await Hive.initFlutter();
    }

    _registerAdapters();

    _profileBox = await Hive.openBox<DonorProfile>('$boxPrefix$profileBoxName');
    _donationsBox =
        await Hive.openBox<DonationRecord>('$boxPrefix$donationsBoxName');
    _bloodCentersBox =
        await Hive.openBox<BloodCenter>('$boxPrefix$bloodCentersBoxName');
    _preferencesBox =
        await Hive.openBox<AppPreferences>('$boxPrefix$preferencesBoxName');
    _metaBox = await Hive.openBox<bool>('$boxPrefix$metaBoxName');

    final alreadySeeded = _metaBox.get(_seededKey) ?? false;
    if (!alreadySeeded) {
      await seedPrototypeData();
    } else {
      if (_bloodCentersBox.isEmpty) {
        await _seedBloodCenters();
      }
      if (_profileBox.get(_profileKey) == null) {
        await _profileBox.put(_profileKey, DonorProfile.initial());
      }
      if (_preferencesBox.get(_preferencesKey) == null) {
        await _preferencesBox.put(_preferencesKey, AppPreferences.initial());
      }
    }
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DonorProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DonationRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BloodCenterAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AppPreferencesAdapter());
    }
  }

  Future<void> _seedBloodCenters() async {
    await _bloodCentersBox.clear();
    for (final center in BloodCenter.initialCenters()) {
      await _bloodCentersBox.put(center.id, center);
    }
  }

  Future<void> seedPrototypeData() async {
    await _profileBox.put(_profileKey, DonorProfile.initial());
    await _preferencesBox.put(_preferencesKey, AppPreferences.initial());
    await _seedBloodCenters();

    await _donationsBox.clear();
    final initialDonations = <DonationRecord>[
      DonationRecord(
        id: 'don-2026-05-12',
        date: DateTime(2026, 5, 12),
        bloodCenterName: 'Hemocentro São Paulo',
        bloodCenterShortName: 'Hemocentro SP',
        cityState: 'São Paulo, SP',
        donationType: 'Sangue Total',
        volumeMl: 450,
        verifiedByCenter: true,
        status: 'Concluída',
      ),
      DonationRecord(
        id: 'don-2026-01-15',
        date: DateTime(2026, 1, 15),
        bloodCenterName: 'Hospital das Clínicas',
        cityState: 'São Paulo, SP',
        donationType: 'Sangue Total',
        volumeMl: 450,
        verifiedByCenter: false,
        status: 'Concluída',
      ),
      DonationRecord(
        id: 'don-2025-10-20',
        date: DateTime(2025, 10, 20),
        bloodCenterName: 'Fundação Pró-Sangue - Clínicas',
        cityState: 'São Paulo, SP',
        donationType: 'Sangue Total',
        volumeMl: 450,
        verifiedByCenter: true,
        status: 'Concluída',
      ),
      DonationRecord(
        id: 'don-2025-06-18',
        date: DateTime(2025, 6, 18),
        bloodCenterName: 'Banco de Sangue Paulista',
        cityState: 'São Paulo, SP',
        donationType: 'Sangue Total',
        volumeMl: 450,
        verifiedByCenter: true,
        status: 'Concluída',
      ),
      DonationRecord(
        id: 'don-2025-02-10',
        date: DateTime(2025, 2, 10),
        bloodCenterName: 'Hemocentro Hospital São Paulo',
        cityState: 'São Paulo, SP',
        donationType: 'Sangue Total',
        volumeMl: 450,
        verifiedByCenter: false,
        status: 'Concluída',
      ),
    ];

    for (final donation in initialDonations) {
      await _donationsBox.put(donation.id, donation);
    }

    await _metaBox.put(_seededKey, true);
  }

  DonorProfile getProfile() {
    return _profileBox.get(_profileKey) ?? DonorProfile.initial();
  }

  Future<void> saveProfile(DonorProfile profile) async {
    await _profileBox.put(_profileKey, profile);
  }

  AppPreferences getPreferences() {
    return _preferencesBox.get(_preferencesKey) ?? AppPreferences.initial();
  }

  Future<void> savePreferences(AppPreferences preferences) async {
    await _preferencesBox.put(_preferencesKey, preferences);
  }

  List<BloodCenter> getBloodCenters() {
    final centers = _bloodCentersBox.values.toList();
    if (centers.isEmpty) {
      return BloodCenter.initialCenters();
    }
    return centers;
  }

  List<DonationRecord> getDonations() {
    final list = _donationsBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> addDonation(DonationRecord record) async {
    await _donationsBox.put(record.id, record);
  }

  Future<void> deleteDonation(String id) async {
    await _donationsBox.delete(id);
  }

  /// Clears donor's personal history and resets profile to a clean blank donor state.
  Future<void> clearAllUserData() async {
    await _donationsBox.clear();
    await _profileBox.put(
      _profileKey,
      DonorProfile(
        fullName: 'Novo Doador',
        email: '',
        bloodType: 'O+',
        biologicalSex: 'Masculino',
        weightKg: 70,
        favoriteBloodCenterId: 'pro-sangue-clinicas',
        favoriteBloodCenterName: 'Fundação Pró-Sangue - Clínicas',
        donorSinceYear: DateTime.now().year,
      ),
    );
    await _preferencesBox.put(_preferencesKey, AppPreferences.initial());
    await _metaBox.put(_seededKey, true);
  }

  /// Restores all initial prototype seed data inside Hive.
  Future<void> resetToPrototypeDefaults() async {
    await seedPrototypeData();
  }
}
