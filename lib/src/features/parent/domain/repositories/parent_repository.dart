import '../entities/linked_student.dart';

abstract interface class ParentRepository {
  Future<List<LinkedStudent>> getLinkedStudents();
}
