import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class SendMoneyPage extends StatefulWidget {
  final double currentBalance;
  final ValueChanged<double> onBalanceUpdated;

  const SendMoneyPage({
    Key? key,
    required this.currentBalance,
    required this.onBalanceUpdated,
  }) : super(key: key);

  @override
  _SendMoneyPageState createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _fetchedContactName;
  bool _isLoading = false;
  double _feeAmount = 0.0;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _amountController.addListener(_calculateTotals);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phone.length == 10 && _fetchedContactName == null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _fetchedContactName = "Abebe Kebede"; 
          });
        }
      });
    } else if (phone.length < 10 && _fetchedContactName != null) {
      setState(() {
        _fetchedContactName = null;
      });
    }
  }

  void _calculateTotals() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _feeAmount = 0.0;
        _totalAmount = 0.0;
      });
      return;
    }

    final enteredAmount = double.tryParse(amountText);
    if (enteredAmount != null && enteredAmount > 0) {
      setState(() {
        _feeAmount = enteredAmount * 0.01; 
        _totalAmount = enteredAmount + _feeAmount;
      });
    } else {
      setState(() {
        _feeAmount = 0.0;
        _totalAmount = 0.0;
      });
    }
  }

  void _onTransferPressed() {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final amountText = _amountController.text.trim();

    if (phone.length != 10 || _fetchedContactName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit Ethiopian number')),
      );
      return;
    }

    final enteredAmount = double.tryParse(amountText) ?? 0.0;
    if (enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_totalAmount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance for this transfer')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Deduct from total balance and sync back
        double newBalance = widget.currentBalance - _totalAmount;
        widget.onBalanceUpdated(newBalance);
        
        _showSuccessDialog(enteredAmount);
      }
    });
  }

  void _showSuccessDialog(double sentAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Transfer Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("To: $_fetchedContactName"),
            Text("Number: ${_phoneController.text}"),
            const SizedBox(height: 10),
            Text("Amount Sent: ${sentAmount.toStringAsFixed(2)} ETB"),
            Text("Fee Charged: ${_feeAmount.toStringAsFixed(2)} ETB"),
            const Divider(),
            Text("Total Deducted: ${_totalAmount.toStringAsFixed(2)} ETB", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF00796B))),
          ),
        ],
      ),
    );
  }

  InputDecoration _telebirrInputDecoration({required String label, IconData? icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF00796B)),
      suffix: suffix,
      filled: true,
      fillColor: Colors.grey[100],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
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
            backgroundColor: const Color(0xFF00796B),
            elevation: 0,
            title: const Text('Send Money'),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Recipient Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _telebirrInputDecoration(
                      label: 'Phone Number (e.g., 0911...)',
                      icon: Icons.phone_android,
                      suffix: _fetchedContactName != null 
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                        : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _fetchedContactName != null ? 40 : 0,
                    child: _fetchedContactName != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, size: 16, color: Colors.teal),
                              const SizedBox(width: 8),
                              Text(
                                "Name: $_fetchedContactName",
                                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Payment Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    decoration: _telebirrInputDecoration(
                      label: 'Amount (ETB)',
                      icon: Icons.money,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedOpacity(
                    opacity: _totalAmount > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Transfer Amount:", style: TextStyle(color: Colors.grey)),
                              Text("${double.tryParse(_amountController.text) ?? 0.0} ETB", style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Service Fee (1%):", style: TextStyle(color: Colors.grey)),
                              Text("${_feeAmount.toStringAsFixed(2)} ETB", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total to Pay:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                "${_totalAmount.toStringAsFixed(2)} ETB", 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00796B))
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onTransferPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                            'TRANSFER', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
}
