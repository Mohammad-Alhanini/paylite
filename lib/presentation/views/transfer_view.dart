import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/wallet_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';

class TransferView extends StatefulWidget {
  const TransferView({super.key});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  final _recipient = TextEditingController();
  final _amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _confirmAndSend() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final walletVM = context.read<WalletViewModel>();
    final recipient = _recipient.text.trim();
    final amount = double.tryParse(_amount.text.trim()) ?? 0;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please confirm the transfer details:'),
            const SizedBox(height: 12),
            _row('Recipient:', recipient),
            _row('Amount:', '${amount.toStringAsFixed(2)} JOD'),
            _row('Fee:', '0.00 JOD'),
            _row('Total:', '${amount.toStringAsFixed(2)} JOD'),
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

    if (ok != true) return;

    final success = await walletVM.sendMoney(
      recipientEmail: recipient,
      amount: amount,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(walletVM.error ?? 'Transfer failed')),
      );
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  String? _validateRecipient(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Recipient email is required';
    if (!value.contains('@') || !value.contains('.')) return 'Invalid email';
    return null;
  }

  String? _validateAmount(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Amount is required';

    final amount = double.tryParse(value);
    if (amount == null) return 'Invalid amount';
    if (amount <= 0) return 'Amount must be greater than 0';
    if (amount > 100.0) return 'Maximum transfer is 100';
    final walletVM = context.read<WalletViewModel>();
    if (amount > walletVM.balance) return 'Insufficient balance';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<WalletViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F3FA),
        elevation: 0,
        title: const Text(
          'Send Money',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: LoadingOverlay(
        isLoading: walletVM.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${walletVM.balance.toStringAsFixed(3)} JOD',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: CustomTextField(
                      controller: _recipient,
                      labelText: 'Recipient Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                      validator: _validateRecipient,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: CustomTextField(
                      controller: _amount,
                      labelText: 'Amount (JOD)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: _validateAmount,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _amountChip('10'),
                    _amountChip('20'),
                    _amountChip('50'),
                    _amountChip('100'),
                  ],
                ),
                const SizedBox(height: 18),
                CustomButton(
                  text: 'Continue to Transfer',
                  backgroundColor: Colors.green,
                  onPressed: _confirmAndSend,
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 0,
                  color: const Color(0xFFD9EEFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info,
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Transfer Rules',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _rule('Minimum amount: 0.01 JOD'),
                        _rule('Maximum per transaction: \$100.00'),
                        _rule('No transfer fees'),
                        _rule('Instant transfer'),
                        _rule('Recipient must have PayLite account'),
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

  Widget _amountChip(String amount) {
    final selected = _amount.text.trim() == amount;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text('$amount JOD'),
          selected: selected,
          onSelected: (_) {
            setState(() {
              _amount.text = amount;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          selectedColor: Colors.grey.shade200,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _rule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('• $text', style: const TextStyle(fontSize: 12)),
    );
  }
}
