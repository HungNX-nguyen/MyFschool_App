import '../entities/teacher_home_summary.dart';

abstract interface class TeacherRepository {
  Future<TeacherHomeSummary> getHomeSummary();
}
