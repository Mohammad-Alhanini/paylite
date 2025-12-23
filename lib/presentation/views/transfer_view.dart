import 'package:flutter/material.dart';
import 'package:paylite/presentation/viewmodels/wallet_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';

class TransferView extends StatefulWidget {
  const TransferView({super.key});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final recipient = _recipientController.text.trim();

      // عرض تأكيد
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Transfer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please confirm the transfer details:'),
              const SizedBox(height: 15),
              _buildDetailRow('Recipient:', recipient),
              _buildDetailRow('Amount:', '${amount.toStringAsFixed(2)} JOD'),
              _buildDetailRow('Fee:', '0.00 JOD'),
              _buildDetailRow('Total:', '${amount.toStringAsFixed(2)} JOD'),
              const SizedBox(height: 10),
              Text(
                'Note: Maximum transfer amount is \$100.00',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm & Send'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await context.read<WalletViewModel>().sendMoney(
          recipientEmail: recipient,
          amount: amount,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transfer completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String? validateRecipient(String? value) {
    if (value == null || value.isEmpty) {
      return 'Recipient email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 100.0) {
      return 'Maximum transfer is \$100.00';
    }

    final walletViewModel = context.read<WalletViewModel>();
    if (amount > walletViewModel.balance) {
      return 'Insufficient balance';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final walletViewModel = context.watch<WalletViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LoadingOverlay(
        isLoading: walletViewModel.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${walletViewModel.formattedBalance} JOD',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (walletViewModel.errorMessage != null)
                          Text(
                            walletViewModel.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  controller: _recipientController,
                  labelText: 'Recipient Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _amountController,
                  labelText: 'Amount (JOD)',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountChip('10'),
                    _buildAmountChip('20'),
                    _buildAmountChip('50'),
                    _buildAmountChip('100'),
                  ],
                ),

                const SizedBox(height: 30),

                CustomButton(
                  text: 'Continue to Transfer',
                  onPressed: _handleTransfer,
                  backgroundColor: Colors.green,
                ),

                const SizedBox(height: 20),

                // Rules Section
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Transfer Rules',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildRuleItem('• Minimum amount: 0.01 JOD'),
                        _buildRuleItem('• Maximum per transaction: \$100.00'),
                        _buildRuleItem('• No transfer fees'),
                        _buildRuleItem('• Instant transfer'),
                        _buildRuleItem('• Recipient must have PayLite account'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountChip(String amount) {
    return ChoiceChip(
      label: Text('$amount JOD'),
      selected: _amountController.text == amount,
      onSelected: (selected) {
        setState(() {
          _amountController.text = amount;
        });
      },
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
