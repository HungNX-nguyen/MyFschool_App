import '../../domain/entities/homeroom_class.dart';

class HomeroomClassModel {
  const HomeroomClassModel({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.academicYearId,
    required this.academicYearName,
  });

  final int classId;
  final String classCode;
  final String className;
  final int academicYearId;
  final String academicYearName;

  factory HomeroomClassModel.fromJson(Map<String, dynamic> json) {
    return HomeroomClassModel(
      classId: (json['classId'] as num).toInt(),
      classCode: json['classCode'] as String,
      className: json['className'] as String,
      academicYearId: (json['academicYearId'] as num).toInt(),
      academicYearName: json['academicYearName'] as String,
    );
  }

  HomeroomClass toEntity() {
    return HomeroomClass(
      classId: classId,
      classCode: classCode,
      className: className,
      academicYearId: academicYearId,
      academicYearName: academicYearName,
    );
  }
}
