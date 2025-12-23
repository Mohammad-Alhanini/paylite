import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paylite/presentation/viewmodels/auth_viewmodel.dart';
import 'package:paylite/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:paylite/presentation/views/login_view.dart';
import 'package:provider/provider.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/custom_button.dart';
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
      context.read<WalletViewModel>().loadLastTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthViewModel>().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, WalletViewModel>(
        builder: (context, authViewModel, walletViewModel, child) {
          return LoadingOverlay(
            isLoading: walletViewModel.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcomeSection(authViewModel),
                  const SizedBox(height: 30),

                  _buildVirtualCard(walletViewModel),
                  const SizedBox(height: 30),

                  _buildQuickActions(context),
                  const SizedBox(height: 30),

                  _buildTransactionHistoryTitle(
                    onRefresh: () {
                      context.read<WalletViewModel>().loadLastTransactions();
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTransactionList(walletViewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(AuthViewModel authViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 5),
        Text(
          FirebaseAuth.instance.currentUser?.email ?? 'User',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVirtualCard(WalletViewModel walletViewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                IconButton(
                  icon: Icon(
                    walletViewModel.isBalanceVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.blue,
                  ),
                  onPressed: walletViewModel.toggleBalanceVisibility,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              walletViewModel.getCurrentBalanceDisplay(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Jordanian Dinar',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Privacy mode: ${walletViewModel.isBalanceVisible ? 'OFF' : 'ON'}',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        CustomButton(
          text: 'Send Money',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransferView()),
            );

            // ✅ بعد الرجوع من التحويل اعمل تحديث للعمليات
            if (!context.mounted) return;
            context.read<WalletViewModel>().loadLastTransactions();
          },
          backgroundColor: Colors.green,
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Request',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Request money feature coming soon'),
                    ),
                  );
                },
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: 'Add Money',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add money feature coming soon'),
                    ),
                  );
                },
                backgroundColor: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionHistoryTitle({required VoidCallback onRefresh}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onRefresh, child: const Text('Refresh')),
      ],
    );
  }

  Widget _buildTransactionList(WalletViewModel walletViewModel) {
    final txs = walletViewModel.recentTransactions;

    if (txs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No transactions yet')),
      );
    }

    return Column(
      children: txs.map((tx) {
        final isReceived = tx.type == 'received';
        final amountText =
            '${isReceived ? '+' : '-'}${tx.amount.toStringAsFixed(2)} JOD';

        final dateText =
            '${tx.createdAt.year}-${tx.createdAt.month.toString().padLeft(2, '0')}-${tx.createdAt.day.toString().padLeft(2, '0')}';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isReceived ? Colors.green[100] : Colors.red[100],
              child: Icon(
                isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                color: isReceived ? Colors.green : Colors.red,
              ),
            ),
            title: Text(tx.recipientEmail),
            subtitle: Text(dateText),
            trailing: Text(
              amountText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isReceived ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
