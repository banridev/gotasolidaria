import 'package:hive/hive.dart';

class DonationRecord {
  DonationRecord({
    required this.id,
    required this.date,
    required this.bloodCenterName,
    this.bloodCenterShortName,
    required this.cityState,
    required this.donationType,
    required this.volumeMl,
    this.notes = '',
    this.verifiedByCenter = false,
    this.status = 'Concluída',
  });

  final String id;
  final DateTime date;
  final String bloodCenterName;
  final String? bloodCenterShortName;
  final String cityState;
  final String donationType; // 'Sangue Total', 'Plaquetas', 'Plasma'
  final int volumeMl;
  final String notes;
  final bool verifiedByCenter;
  final String status;

  static const List<String> donationTypes = [
    'Sangue Total',
    'Plaquetas',
    'Plasma',
  ];

  String get displayShortName =>
      (bloodCenterShortName != null && bloodCenterShortName!.isNotEmpty)
          ? bloodCenterShortName!
          : bloodCenterName;

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String get dayTwoDigits => date.day.toString().padLeft(2, '0');

  String get monthYearFormatted {
    final month = date.month.toString().padLeft(2, '0');
    return '$month/${date.year}';
  }

  String get typeAndVolume => '$donationType · ${volumeMl}ml';
}

class DonationRecordAdapter extends TypeAdapter<DonationRecord> {
  @override
  final int typeId = 1;

  @override
  DonationRecord read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return DonationRecord(
      id: fields[0] as String,
      date: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      bloodCenterName: fields[2] as String,
      bloodCenterShortName: fields[3] as String?,
      cityState: fields[4] as String? ?? 'São Paulo, SP',
      donationType: fields[5] as String? ?? 'Sangue Total',
      volumeMl: fields[6] as int? ?? 450,
      notes: fields[7] as String? ?? '',
      verifiedByCenter: fields[8] as bool? ?? false,
      status: fields[9] as String? ?? 'Concluída',
    );
  }

  @override
  void write(BinaryWriter writer, DonationRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.bloodCenterName)
      ..writeByte(3)
      ..write(obj.bloodCenterShortName)
      ..writeByte(4)
      ..write(obj.cityState)
      ..writeByte(5)
      ..write(obj.donationType)
      ..writeByte(6)
      ..write(obj.volumeMl)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.verifiedByCenter)
      ..writeByte(9)
      ..write(obj.status);
  }
}
