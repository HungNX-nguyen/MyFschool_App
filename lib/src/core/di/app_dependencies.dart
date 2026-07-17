import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';
import '../../features/homeroom/data/datasources/homeroom_remote_datasource.dart';
import '../../features/homeroom/data/repositories/homeroom_repository_impl.dart';
import '../../features/homeroom/domain/repositories/homeroom_repository.dart';
import '../../features/homeroom/presentation/controllers/homeroom_controller.dart';
import '../../features/learning_result/data/datasources/learning_result_remote_datasource.dart';
import '../../features/learning_result/data/repositories/learning_result_repository_impl.dart';
import '../../features/learning_result/domain/repositories/learning_result_repository.dart';
import '../../features/learning_result/presentation/controllers/learning_result_controller.dart';
import '../../features/leave_absence/data/datasources/leave_absence_remote_datasource.dart';
import '../../features/leave_absence/data/repositories/leave_request_repository_impl.dart';
import '../../features/leave_absence/domain/repositories/leave_request_repository.dart';
import '../../features/leave_absence/presentation/controllers/parent_leave_request_controller.dart';
import '../../features/leave_absence/presentation/controllers/teacher_leave_request_controller.dart';
import '../../features/notification/data/datasources/app_notification_remote_datasource.dart';
import '../../features/notification/data/repositories/app_notification_repository_impl.dart';
import '../../features/notification/presentation/controllers/app_notification_controller.dart';
import '../../features/parent/data/datasources/parent_remote_datasource.dart';
import '../../features/parent/data/repositories/parent_repository_impl.dart';
import '../../features/parent/presentation/controllers/parent_home_controller.dart';
import '../../features/school_event/data/datasources/school_event_remote_datasource.dart';
import '../../features/school_event/data/repositories/school_event_repository_impl.dart';
import '../../features/school_event/domain/repositories/school_event_repository.dart';
import '../../features/school_event/presentation/controllers/school_event_controller.dart';
import '../../features/timetable/data/datasources/timetable_remote_datasource.dart';
import '../../features/timetable/data/repositories/timetable_repository_impl.dart';
import '../../features/timetable/domain/repositories/timetable_repository.dart';
import '../../features/timetable/presentation/controllers/timetable_controller.dart';
import '../../features/teacher/data/datasources/teacher_remote_datasource.dart';
import '../../features/teacher/data/repositories/teacher_repository_impl.dart';
import '../../features/teacher/presentation/controllers/teacher_home_controller.dart';
import '../../features/teacher_communication/data/datasources/teacher_communication_remote_datasource.dart';
import '../../features/teacher_communication/data/repositories/teacher_communication_repository_impl.dart';
import '../../features/teacher_communication/domain/repositories/teacher_communication_repository.dart';
import '../../features/teacher_communication/presentation/controllers/teacher_communication_controller.dart';
import '../network/api_client.dart';
import '../session/inactivity_session_controller.dart';
import '../storage/secure_session_storage.dart';

class AppDependencies {
  AppDependencies._({
    required ApiClient apiClient,
    required HomeroomRepository homeroomRepository,
    required LearningResultRepository learningResultRepository,
    required LeaveRequestRepository leaveRequestRepository,
    required SchoolEventRepository schoolEventRepository,
    required TeacherCommunicationRepository teacherCommunicationRepository,
    required TimetableRepository timetableRepository,
    required this.inactivitySessionController,
    required this.loginController,
    required this.notificationController,
    required this.parentHomeController,
    required this.teacherHomeController,
  }) : _apiClient = apiClient,
       _homeroomRepository = homeroomRepository,
       _learningResultRepository = learningResultRepository,
       _leaveRequestRepository = leaveRequestRepository,
       _schoolEventRepository = schoolEventRepository,
       _teacherCommunicationRepository = teacherCommunicationRepository,
       _timetableRepository = timetableRepository;

  factory AppDependencies.production() {
    final apiClient = ApiClient();
    final sessionStorage = SecureSessionStorage();
    final authRemoteDatasource = AuthRemoteDatasource(apiClient);
    final authRepository = AuthRepositoryImpl(
      authRemoteDatasource,
      sessionStorage,
    );
    final loginController = LoginController(authRepository);
    final inactivitySessionController = InactivitySessionController(
      onTimeout: loginController.expireInactiveSession,
    );
    apiClient.onRefreshAccessToken = loginController.refreshAccessToken;
    apiClient.onUnauthorized = loginController.expireSession;
    final parentRemoteDatasource = ParentRemoteDatasource(apiClient);
    final parentRepository = ParentRepositoryImpl(
      parentRemoteDatasource,
      sessionStorage,
    );
    final teacherRemoteDatasource = TeacherRemoteDatasource(apiClient);
    final teacherRepository = TeacherRepositoryImpl(
      teacherRemoteDatasource,
      sessionStorage,
    );
    final timetableRemoteDatasource = TimetableRemoteDatasource(apiClient);
    final timetableRepository = TimetableRepositoryImpl(
      timetableRemoteDatasource,
      sessionStorage,
    );
    final learningResultRemoteDatasource = LearningResultRemoteDatasource(
      apiClient,
    );
    final learningResultRepository = LearningResultRepositoryImpl(
      learningResultRemoteDatasource,
      sessionStorage,
    );
    final leaveAbsenceRemoteDatasource = LeaveAbsenceRemoteDatasource(
      apiClient,
    );
    final leaveRequestRepository = LeaveRequestRepositoryImpl(
      leaveAbsenceRemoteDatasource,
      sessionStorage,
    );
    final schoolEventRemoteDatasource = SchoolEventRemoteDatasource(apiClient);
    final schoolEventRepository = SchoolEventRepositoryImpl(
      schoolEventRemoteDatasource,
      sessionStorage,
    );
    final homeroomRemoteDatasource = HomeroomRemoteDatasource(apiClient);
    final homeroomRepository = HomeroomRepositoryImpl(
      homeroomRemoteDatasource,
      sessionStorage,
    );
    final teacherCommunicationRemoteDatasource =
        TeacherCommunicationRemoteDatasource(apiClient);
    final teacherCommunicationRepository = TeacherCommunicationRepositoryImpl(
      teacherCommunicationRemoteDatasource,
      sessionStorage,
    );
    final notificationRemoteDatasource = AppNotificationRemoteDatasource(
      apiClient,
    );
    final notificationRepository = AppNotificationRepositoryImpl(
      notificationRemoteDatasource,
      sessionStorage,
    );

    return AppDependencies._(
      apiClient: apiClient,
      homeroomRepository: homeroomRepository,
      learningResultRepository: learningResultRepository,
      leaveRequestRepository: leaveRequestRepository,
      schoolEventRepository: schoolEventRepository,
      teacherCommunicationRepository: teacherCommunicationRepository,
      timetableRepository: timetableRepository,
      inactivitySessionController: inactivitySessionController,
      loginController: loginController,
      notificationController: AppNotificationController(
        notificationRepository,
        schoolEventRepository,
      ),
      parentHomeController: ParentHomeController(parentRepository),
      teacherHomeController: TeacherHomeController(teacherRepository),
    );
  }

  final ApiClient _apiClient;
  final HomeroomRepository _homeroomRepository;
  final LearningResultRepository _learningResultRepository;
  final LeaveRequestRepository _leaveRequestRepository;
  final SchoolEventRepository _schoolEventRepository;
  final TeacherCommunicationRepository _teacherCommunicationRepository;
  final TimetableRepository _timetableRepository;
  final InactivitySessionController inactivitySessionController;
  final LoginController loginController;
  final AppNotificationController notificationController;
  final ParentHomeController parentHomeController;
  final TeacherHomeController teacherHomeController;

  HomeroomController createHomeroomController() {
    return HomeroomController(_homeroomRepository);
  }

  TimetableController createParentTimetableController(int studentId) {
    return TimetableController(
      _timetableRepository,
      audience: TimetableAudience.parent,
      studentId: studentId,
    );
  }

  TimetableController createStudentTimetableController() {
    return TimetableController(
      _timetableRepository,
      audience: TimetableAudience.student,
    );
  }

  TimetableController createTeacherTimetableController() {
    return TimetableController(
      _timetableRepository,
      audience: TimetableAudience.teacher,
    );
  }

  LearningResultController createParentLearningResultController(int studentId) {
    return LearningResultController(
      _learningResultRepository,
      audience: LearningResultAudience.parent,
      studentId: studentId,
    );
  }

  LearningResultController createStudentLearningResultController() {
    return LearningResultController(
      _learningResultRepository,
      audience: LearningResultAudience.student,
    );
  }

  ParentLeaveRequestController createParentLeaveRequestController(
    int studentId,
  ) {
    return ParentLeaveRequestController(
      _leaveRequestRepository,
      studentId: studentId,
    );
  }

  TeacherLeaveRequestController createTeacherLeaveRequestController() {
    return TeacherLeaveRequestController(_leaveRequestRepository);
  }

  TeacherCommunicationController createTeacherCommunicationController() {
    return TeacherCommunicationController(_teacherCommunicationRepository);
  }

  SchoolEventController createParentSchoolEventController(int studentId) {
    return SchoolEventController(
      _schoolEventRepository,
      audience: SchoolEventAudience.parent,
      studentId: studentId,
    );
  }

  SchoolEventController createStudentSchoolEventController() {
    return SchoolEventController(
      _schoolEventRepository,
      audience: SchoolEventAudience.student,
    );
  }

  void dispose() {
    inactivitySessionController.dispose();
    loginController.dispose();
    notificationController.dispose();
    parentHomeController.dispose();
    teacherHomeController.dispose();
    _apiClient.close();
  }
}
