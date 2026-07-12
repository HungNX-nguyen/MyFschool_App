import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';
import '../network/api_client.dart';
import '../storage/secure_session_storage.dart';

class AppDependencies {
  AppDependencies._({
    required ApiClient apiClient,
    required this.loginController,
  }) : _apiClient = apiClient;

  factory AppDependencies.production() {
    final apiClient = ApiClient();
    final remoteDatasource = AuthRemoteDatasource(apiClient);
    final sessionStorage = SecureSessionStorage();
    final authRepository = AuthRepositoryImpl(
      remoteDatasource,
      sessionStorage,
    );

    return AppDependencies._(
      apiClient: apiClient,
      loginController: LoginController(authRepository),
    );
  }

  final ApiClient _apiClient;
  final LoginController loginController;

  void dispose() {
    loginController.dispose();
    _apiClient.close();
  }
}
