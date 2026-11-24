import 'package:hive/hive.dart';

class DonorProfile {
  DonorProfile({
    required this.fullName,
    required this.email,
    required this.bloodType,
    required this.biologicalSex,
    required this.weightKg,
    required this.favoriteBloodCenterId,
    required this.favoriteBloodCenterName,
    required this.donorSinceYear,
  });

  final String fullName;
  final String email;
  final String bloodType;
  final String biologicalSex; // 'Masculino' ou 'Feminino'
  final int weightKg;
  final String favoriteBloodCenterId;
  final String favoriteBloodCenterName;
  final int donorSinceYear;

  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  bool get isMale => biologicalSex == 'Masculino';

  int get donationIntervalDays => isMale ? 60 : 90;

  int get maxDonationsPerYear => isMale ? 4 : 3;

  bool get isWeightEligible => weightKg >= 50;

  String get intervalSummary =>
      isMale ? 'Homem (60 dias)' : 'Mulher (90 dias)';

  String get weightSummary => isWeightEligible
      ? '$weightKg kg (Apto > 50kg)'
      : '$weightKg kg (Inapto < 50kg)';

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'D';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  DonorProfile copyWith({
    String? fullName,
    String? email,
    String? bloodType,
    String? biologicalSex,
    int? weightKg,
    String? favoriteBloodCenterId,
    String? favoriteBloodCenterName,
    int? donorSinceYear,
  }) {
    return DonorProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      bloodType: bloodType ?? this.bloodType,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      weightKg: weightKg ?? this.weightKg,
      favoriteBloodCenterId:
          favoriteBloodCenterId ?? this.favoriteBloodCenterId,
      favoriteBloodCenterName:
          favoriteBloodCenterName ?? this.favoriteBloodCenterName,
      donorSinceYear: donorSinceYear ?? this.donorSinceYear,
    );
  }

  factory DonorProfile.initial() {
    return DonorProfile(
      fullName: 'Carlos Silva',
      email: 'carlos.silva@email.com',
      bloodType: 'O+',
      biologicalSex: 'Masculino',
      weightKg: 72,
      favoriteBloodCenterId: 'pro-sangue-clinicas',
      favoriteBloodCenterName: 'Fundação Pró-Sangue - Clínicas',
      donorSinceYear: 2024,
    );
  }
}

class DonorProfileAdapter extends TypeAdapter<DonorProfile> {
  @override
  final int typeId = 0;

  @override
  DonorProfile read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return DonorProfile(
      fullName: fields[0] as String? ?? 'Carlos Silva',
      email: fields[1] as String? ?? 'carlos.silva@email.com',
      bloodType: fields[2] as String? ?? 'O+',
      biologicalSex: fields[3] as String? ?? 'Masculino',
      weightKg: fields[4] as int? ?? 72,
      favoriteBloodCenterId: fields[5] as String? ?? 'pro-sangue-clinicas',
      favoriteBloodCenterName:
          fields[6] as String? ?? 'Fundação Pró-Sangue - Clínicas',
      donorSinceYear: fields[7] as int? ?? 2024,
    );
  }

  @override
  void write(BinaryWriter writer, DonorProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fullName)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.bloodType)
      ..writeByte(3)
      ..write(obj.biologicalSex)
      ..writeByte(4)
      ..write(obj.weightKg)
      ..writeByte(5)
      ..write(obj.favoriteBloodCenterId)
      ..writeByte(6)
      ..write(obj.favoriteBloodCenterName)
      ..writeByte(7)
      ..write(obj.donorSinceYear);
  }
}
