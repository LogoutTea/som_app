import 'package:hive/hive.dart';

part 'partner.g.dart';  // Подключение сгенерированного файла

@HiveType(typeId: 0)    // Уникальный идентификатор типа
class Partner extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String code;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String type;
  
  @HiveField(4)
  final String inn;
  
  @HiveField(5)
  final String phone;

  Partner({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.inn,
    required this.phone,
  });
}
