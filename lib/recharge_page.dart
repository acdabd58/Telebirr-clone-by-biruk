import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class RechargePage extends StatefulWidget {
  const RechargePage({Key? key}) : super(key: key);

  @override
  _RechargePageState createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final _amountController = TextEditingController();
  
  // Initial starting balance set to 100,000.00 ETB
  double _currentBalance = 100000.00;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Quick amount modifier helper (+100, +500, etc.)
  void _addQuickAmount(int amount) {
    final currentVal = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _amountController.text = (currentVal + amount).toStringAsFixed(0);
    });
  }

  void _onConfirmRecharge() {
    final amountText = _amountController.text.trim();
    final rechargeAmount = double.tryParse(amountText);

    if (rechargeAmount == null || rechargeAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid recharge amount')),
      );
      return;
    }

    // Start loading animation (Telebirr style)
    setState(() {
      _isLoading = true;
    });

    // Simulate backend network delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentBalance += rechargeAmount; // Add to balance
          _isLoading = false;
        });
        _showSuccessDialog(rechargeAmount);
      }
    });
  }

  void _showSuccessDialog(double addedAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Recharge Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Successfully added: ${addedAmount.toStringAsFixed(2)} ETB"),
            const SizedBox(height: 8),
            Text("New Balance: ${_currentBalance.toStringAsFixed(2)} ETB", 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF00796B))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF00796B), // Telebirr Teal
            title: const Text('Top Up / Recharge'),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Balance Card ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        "${_currentBalance.toStringAsFixed(2)} ETB",
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                const Text("Enter Amount (ETB)", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                const SizedBox(height: 10),

                // --- Amount Input Field ---
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'e.g., 1000',
                    prefixIcon: const Icon(Icons.money, color: Color(0xFF00796B)),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Quick Amount Chips (+100, +500, etc.) ---
                Wrap(
                  spacing: 10,
                  children: [
                    _buildQuickChip(100),
                    _buildQuickChip(500),
                    _buildQuickChip(1000),
                    _buildQuickChip(5000),
                  ],
                ),
                const SizedBox(height: 35),

                // --- Payment Method Section ---
                const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Color(0xFF00796B)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Telebirr Wallet (Default)", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Instant Top-up", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Color(0xFF00796B)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- Confirm Button ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onConfirmRecharge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'CONFIRM RECHARGE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- Telebirr Loading Screen Overlay ---
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF00796B)),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickChip(int amount) {
    return ActionChip(
      backgroundColor: Colors.teal[50],
      label: Text("+$amount ETB", style: const TextStyle(color: Color(0xFF00796B))),
      onPressed: () => _addQuickAmount(amount),
    );
  }
}
