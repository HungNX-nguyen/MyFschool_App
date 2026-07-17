import '../../domain/entities/linked_student.dart';

class LinkedStudentModel {
  const LinkedStudentModel({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.isPrimaryContact,
    this.classId,
    this.className,
    this.relationship,
  });

  final int id;
  final String studentCode;
  final String fullName;
  final int? classId;
  final String? className;
  final String? relationship;
  final bool isPrimaryContact;

  factory LinkedStudentModel.fromJson(Map<String, dynamic> json) {
    return LinkedStudentModel(
      id: (json['studentId'] as num).toInt(),
      studentCode: json['studentCode'] as String,
      fullName: json['fullName'] as String,
      classId: (json['classId'] as num?)?.toInt(),
      className: json['className'] as String?,
      relationship: json['relationship'] as String?,
      isPrimaryContact: json['isPrimaryContact'] as bool,
    );
  }

  LinkedStudent toEntity() {
    return LinkedStudent(
      id: id,
      studentCode: studentCode,
      fullName: fullName,
      classId: classId,
      className: className,
      relationship: relationship,
      isPrimaryContact: isPrimaryContact,
    );
  }
}
