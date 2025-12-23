import 'package:paylite/core/services/biometric_service.dart';
import 'package:paylite/core/services/secure_storage_service.dart';
import 'package:paylite/data/datasources/auth_remote_data_source.dart';
import 'package:paylite/data/repositories/auth_repository_impl.dart';
import 'package:paylite/data/repositories/wallet_repository_impl.dart';
import 'package:paylite/domain/repositories/auth_repository.dart';
import 'package:paylite/domain/repositories/wallet_repository.dart';
import 'package:paylite/domain/usecases/auth_usecase.dart';
import 'package:paylite/domain/usecases/wallet_usecases.dart';
import 'package:paylite/presentation/viewmodels/auth_viewmodel.dart';
import 'package:paylite/presentation/viewmodels/wallet_viewmodel.dart';

class DI {
  static late final AuthViewModel authViewModel;
  static late final WalletViewModel walletViewModel;

  static void init() {
    final secureStorage = SecureStorageService();
    final biometricService = BiometricService();

    final authRemoteDataSource = AuthRemoteDataSource();

    final AuthRepository authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      secureStorage: secureStorage,
      biometricService: biometricService,
    );

    final WalletRepository walletRepository = WalletRepositoryImpl();

    final signInUseCase = SignInUseCase(authRepository: authRepository);
    final signOutUseCase = SignOutUseCase(authRepository: authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(
      authRepository: authRepository,
    );

    final authenticateWithBiometricsUseCase = AuthenticateWithBiometricsUseCase(
      authRepository: authRepository,
    );
    final saveBiometricPreferenceUseCase = SaveBiometricPreferenceUseCase(
      authRepository: authRepository,
    );
    final isBiometricEnabledUseCase = IsBiometricEnabledUseCase(
      authRepository: authRepository,
    );
    final shouldReAuthenticateUseCase = ShouldReAuthenticateUseCase(
      authRepository: authRepository,
    );

    final getBalanceUseCase = GetBalanceUseCase(
      walletRepository: walletRepository,
    );
    final sendMoneyUseCase = SendMoneyUseCase(
      walletRepository: walletRepository,
    );
    final getTransactionsUseCase = GetTransactionsUseCase(
      walletRepository: walletRepository,
    );
    final toggleBalanceVisibilityUseCase = ToggleBalanceVisibilityUseCase();

    authViewModel = AuthViewModel(
      signInUseCase: signInUseCase,
      signOutUseCase: signOutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      authenticateWithBiometricsUseCase: authenticateWithBiometricsUseCase,
      saveBiometricPreferenceUseCase: saveBiometricPreferenceUseCase,
      isBiometricEnabledUseCase: isBiometricEnabledUseCase,
      shouldReAuthenticateUseCase: shouldReAuthenticateUseCase,
    );

    walletViewModel = WalletViewModel(
      getBalanceUseCase: getBalanceUseCase,
      sendMoneyUseCase: sendMoneyUseCase,
      getTransactionsUseCase: getTransactionsUseCase,
      toggleBalanceVisibilityUseCase: toggleBalanceVisibilityUseCase,
    );
  }
}
