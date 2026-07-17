class LinkedStudent {
  const LinkedStudent({
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
}
