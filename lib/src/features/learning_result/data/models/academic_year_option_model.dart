import '../../domain/entities/learning_result.dart';

class AcademicYearOptionModel {
  const AcademicYearOptionModel({required this.id, required this.name});

  final int id;
  final String name;

  factory AcademicYearOptionModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearOptionModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );
  }

  AcademicYearOption toEntity() => AcademicYearOption(id: id, name: name);
}
