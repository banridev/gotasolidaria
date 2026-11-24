import 'package:hive/hive.dart';

class AppPreferences {
  AppPreferences({
    required this.darkMode,
    required this.criticalStockAlerts,
    required this.donationReminder,
    this.avatarStyleIndex = 0,
  });

  final bool darkMode;
  final bool criticalStockAlerts;
  final bool donationReminder;
  final int avatarStyleIndex;

  AppPreferences copyWith({
    bool? darkMode,
    bool? criticalStockAlerts,
    bool? donationReminder,
    int? avatarStyleIndex,
  }) {
    return AppPreferences(
      darkMode: darkMode ?? this.darkMode,
      criticalStockAlerts: criticalStockAlerts ?? this.criticalStockAlerts,
      donationReminder: donationReminder ?? this.donationReminder,
      avatarStyleIndex: avatarStyleIndex ?? this.avatarStyleIndex,
    );
  }

  factory AppPreferences.initial() {
    return AppPreferences(
      darkMode: false,
      criticalStockAlerts: true,
      donationReminder: true,
      avatarStyleIndex: 0,
    );
  }
}

class AppPreferencesAdapter extends TypeAdapter<AppPreferences> {
  @override
  final int typeId = 3;

  @override
  AppPreferences read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return AppPreferences(
      darkMode: fields[0] as bool? ?? false,
      criticalStockAlerts: fields[1] as bool? ?? true,
      donationReminder: fields[2] as bool? ?? true,
      avatarStyleIndex: fields[3] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, AppPreferences obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.darkMode)
      ..writeByte(1)
      ..write(obj.criticalStockAlerts)
      ..writeByte(2)
      ..write(obj.donationReminder)
      ..writeByte(3)
      ..write(obj.avatarStyleIndex);
  }
}
