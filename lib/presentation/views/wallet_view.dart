import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payliteapp/presentation/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/wallet_viewmodel.dart';
import '../widgets/loading_overlay.dart';
import 'login_view.dart';
import 'transfer_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletViewModel>().refresh();
    });
  }

  void _comingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('the feature coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final walletVM = context.watch<WalletViewModel>();

    final email = FirebaseAuth.instance.currentUser?.email ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F3FA),
        elevation: 0,
        title: const Text(
          'My Wallet',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: walletVM.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _welcome(email),
              const SizedBox(height: 20),
              _balanceCard(walletVM),
              const SizedBox(height: 28),
              _sectionTitle('Quick Actions'),
              const SizedBox(height: 14),
              CustomButton(
                text: 'Send Money',
                backgroundColor: Colors.green,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferView()),
                  );
                  if (!context.mounted) return;
                  context.read<WalletViewModel>().refresh();
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Request',
                      backgroundColor: Colors.orange,
                      onPressed: _comingSoon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Add Money',
                      backgroundColor: Colors.purple,
                      onPressed: _comingSoon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _transactionsHeader(walletVM),
              const SizedBox(height: 12),
              _transactionsList(walletVM),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcome(String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _balanceCard(WalletViewModel walletVM) {
    final amountText = walletVM.showBalance
        ? '${walletVM.balance.toStringAsFixed(3)} JOD'
        : '******';

    return Card(
      elevation: 6,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                IconButton(
                  onPressed: walletVM.toggleBalance,
                  icon: Icon(
                    walletVM.showBalance
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              amountText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jordanian Dinar',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Privacy mode: ${walletVM.showBalance ? 'OFF' : 'ON'}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _transactionsHeader(WalletViewModel walletVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle('Recent Transactions'),
        TextButton(onPressed: walletVM.refresh, child: const Text('Refresh')),
      ],
    );
  }

  Widget _transactionsList(WalletViewModel walletVM) {
    final txs = walletVM.recent;

    if (txs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Center(child: Text('No transactions yet')),
      );
    }

    return Column(
      children: txs.map((tx) {
        final isReceived = tx.type == 'received';
        final sign = isReceived ? '+' : '-';
        final amountText = '$sign${tx.amount.toStringAsFixed(2)} JOD';
        final dateText =
            '${tx.createdAt.year}-${tx.createdAt.month.toString().padLeft(2, '0')}-${tx.createdAt.day.toString().padLeft(2, '0')}';

        final bg = isReceived ? Colors.green[100] : Colors.red[100];
        final icon = isReceived ? Icons.arrow_downward : Icons.arrow_upward;
        final amountColor = isReceived ? Colors.green : Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: bg,
                child: Icon(icon, color: amountColor),
              ),
              title: Text(
                tx.recipientEmail,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                dateText,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              trailing: Text(
                amountText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
