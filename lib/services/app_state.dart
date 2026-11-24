import 'package:material_ui/material_ui.dart';

import '../models/app_preferences.dart';
import '../models/blood_center.dart';
import '../models/donation_record.dart';
import '../models/donor_profile.dart';
import 'hive_service.dart';

class AppState extends ChangeNotifier {
  AppState(this._hive) {
    _reloadFromHive();
  }

  final HiveService _hive;

  late DonorProfile _profile;
  late AppPreferences _preferences;
  late List<DonationRecord> _donations;
  late List<BloodCenter> _bloodCenters;

  DonorProfile get profile => _profile;
  AppPreferences get preferences => _preferences;
  List<DonationRecord> get donations => List.unmodifiable(_donations);
  List<BloodCenter> get bloodCenters => List.unmodifiable(_bloodCenters);

  ThemeMode get themeMode =>
      _preferences.darkMode ? ThemeMode.dark : ThemeMode.light;

  int get totalDonations => _donations.length;

  int get livesImpacted => totalDonations * 4;

  DonationRecord? get latestDonation =>
      _donations.isEmpty ? null : _donations.first;

  String get donorTier {
    if (totalDonations >= 10) return 'Doador Ouro';
    if (totalDonations >= 3) return 'Doador Prata';
    return 'Doador Bronze';
  }

  String get donorTierSummary {
    final suffix = totalDonations == 1 ? 'doação' : 'doações';
    return '$donorTier • $totalDonations $suffix';
  }

  /// Computes remaining days until the donor fulfills the recommended interval.
  int get daysRemaining {
    final latest = latestDonation;
    if (latest == null) return 0;

    final nextDate =
        latest.date.add(Duration(days: _profile.donationIntervalDays));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(nextDate.year, nextDate.month, nextDate.day);

    if (!target.isAfter(today)) return 0;
    return target.difference(today).inDays;
  }

  DateTime? get nextEligibleDate {
    final latest = latestDonation;
    if (latest == null) return null;
    return latest.date.add(Duration(days: _profile.donationIntervalDays));
  }

  bool get isEligibleToDonate =>
      daysRemaining == 0 && _profile.isWeightEligible;

  double get eligibilityProgress {
    if (daysRemaining == 0) return 1.0;
    final interval = _profile.donationIntervalDays;
    final elapsed = (interval - daysRemaining).clamp(0, interval);
    return elapsed / interval;
  }

  List<int> get availableYears {
    final years = <int>{2026, 2025};
    for (final d in _donations) {
      years.add(d.date.year);
    }
    final sorted = years.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  List<DonationRecord> donationsForYear(int? year) {
    if (year == null) return donations;
    return _donations.where((d) => d.date.year == year).toList();
  }

  void _reloadFromHive() {
    _profile = _hive.getProfile();
    _preferences = _hive.getPreferences();
    _donations = _hive.getDonations();
    _bloodCenters = _hive.getBloodCenters();
  }

  Future<void> addDonation({
    required DateTime date,
    required BloodCenter bloodCenter,
    required String donationType,
    required int volumeMl,
    required String notes,
  }) async {
    final record = DonationRecord(
      id: 'don-${DateTime.now().microsecondsSinceEpoch}',
      date: DateTime(date.year, date.month, date.day),
      bloodCenterName: bloodCenter.name,
      cityState: bloodCenter.cityState,
      donationType: donationType,
      volumeMl: volumeMl,
      notes: notes.trim(),
      verifiedByCenter: false,
      status: 'Concluída',
    );
    await _hive.addDonation(record);
    _reloadFromHive();
    notifyListeners();
  }

  Future<void> deleteDonation(String id) async {
    await _hive.deleteDonation(id);
    _reloadFromHive();
    notifyListeners();
  }

  Future<void> updateProfile(DonorProfile updated) async {
    await _hive.saveProfile(updated);
    _reloadFromHive();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await _hive.savePreferences(_preferences.copyWith(darkMode: value));
    _reloadFromHive();
    notifyListeners();
  }

  Future<void> setCriticalStockAlerts(bool value) async {
    await _hive
        .savePreferences(_preferences.copyWith(criticalStockAlerts: value));
    _reloadFromHive();
    notifyListeners();
  }

  Future<void> setDonationReminder(bool value) async {
    await _hive.savePreferences(_preferences.copyWith(donationReminder: value));
    _reloadFromHive();
    notifyListeners();
  }

  Future<void> setAvatarStyleIndex(int index) async {
    await _hive.savePreferences(_preferences.copyWith(avatarStyleIndex: index));
    _reloadFromHive();
    notifyListeners();
  }

  Future<void> clearAllUserData() async {
    await _hive.clearAllUserData();
    _reloadFromHive();
    notifyListeners();
  }

  Future<void> resetToPrototypeDefaults() async {
    await _hive.resetToPrototypeDefaults();
    _reloadFromHive();
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
