import 'package:hive/hive.dart';

class BloodCenter {
  BloodCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.cityState,
    required this.neighborhood,
  });

  final String id;
  final String name;
  final String address;
  final String cityState;
  final String neighborhood;

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return name.toLowerCase().contains(normalized) ||
        address.toLowerCase().contains(normalized) ||
        neighborhood.toLowerCase().contains(normalized) ||
        cityState.toLowerCase().contains(normalized);
  }

  static List<BloodCenter> initialCenters() => [
        BloodCenter(
          id: 'pro-sangue-clinicas',
          name: 'Fundação Pró-Sangue - Clínicas',
          address: 'Av. Dr. Enéas Carvalho, 155',
          cityState: 'São Paulo, SP',
          neighborhood: 'Cerqueira César',
        ),
        BloodCenter(
          id: 'banco-sangue-paulista',
          name: 'Banco de Sangue Paulista',
          address: 'R. Dr. Alceu de Campos, 46',
          cityState: 'São Paulo, SP',
          neighborhood: 'Jardim Paulista',
        ),
        BloodCenter(
          id: 'hemocentro-hsp',
          name: 'Hemocentro Hospital São Paulo',
          address: 'R. Napoleão de Barros, 715',
          cityState: 'São Paulo, SP',
          neighborhood: 'Vila Clementino',
        ),
        BloodCenter(
          id: 'posto-barueri',
          name: 'Posto Barueri - Pró-Sangue',
          address: 'R. Angela Mirella, 354',
          cityState: 'Barueri, SP',
          neighborhood: 'Jardim Barueri',
        ),
      ];
}

class BloodCenterAdapter extends TypeAdapter<BloodCenter> {
  @override
  final int typeId = 2;

  @override
  BloodCenter read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return BloodCenter(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      cityState: fields[3] as String? ?? 'São Paulo, SP',
      neighborhood: fields[4] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, BloodCenter obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.cityState)
      ..writeByte(4)
      ..write(obj.neighborhood);
  }
}
