import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:payliteapp/data/datasources/auth_remote_datasource.dart';
import 'package:payliteapp/data/datasources/wallet_remote_datasource.dart';
import 'package:provider/provider.dart';
import 'core/services/biometric_service.dart';
import 'core/services/secure_storage_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/wallet_viewmodel.dart';
import 'presentation/views/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorageService();
    final biometric = BiometricService();

    final authRemote = AuthRemoteDataSource();
    final walletRemote = WalletRemoteDataSource();

    final authRepo = AuthRepositoryImpl(authRemote, storage, biometric);
    final walletRepo = WalletRepositoryImpl(walletRemote);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepo)..loadUserIfAny(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletViewModel(walletRepo)..init(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}
