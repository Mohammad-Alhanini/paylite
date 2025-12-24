import 'package:flutter/material.dart';
import 'package:payliteapp/presentation/views/wallet_view.dart';
import 'package:payliteapp/presentation/widgets/custom_button.dart';
import 'package:payliteapp/presentation/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/loading_overlay.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController(text: 'test@example.com');
  final _password = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authVM = context.read<AuthViewModel>();

    try {
      await authVM.login(_email.text, _password.text);
      final ok = await authVM.biometricAuth();

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authVM.error ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authVM.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'PayLite Wallet',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 60),
                CustomTextField(
                  controller: _email,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _password,
                  labelText: 'Password',
                  obscureText: true,
                  prefixIcon: Icons.lock,
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Password too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Login',
                  onPressed: _login,
                  isLoading: authVM.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
