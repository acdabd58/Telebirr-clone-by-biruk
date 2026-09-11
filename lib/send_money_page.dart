import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatter
import 'dart:async'; // For Future.delayed

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({Key? key}) : super(key: key);

  @override
  _SendMoneyPageState createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  // State variables for UI logic
  String? _fetchedContactName;
  bool _isLoading = false;
  double _feeAmount = 0.0;
  double _totalAmount = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to recalculate whenever input changes
    _phoneController.addListener(_onPhoneChanged);
    _amountController.addListener(_calculateTotals);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // --- Logic ---

  // Simulate fetching a name when phone number reaches 10 digits
  void _onPhoneChanged() {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), ''); // Clean formatting
    
    if (phone.length == 10 && _fetchedContactName == null) {
      // Simulate network delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            // MOCK NAME: Replace this with actual contact lookup if you integrate contacts
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

  // Calculate 1% fee and total
  void _calculateTotals() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _feeAmount = 0.0;
        _totalAmount = 0.0;
      });
      return;
    }

    finalenteredAmount = double.tryParse(amountText);
    if (enteredAmount != null && enteredAmount > 0) {
      setState(() {
        // Telebirr typically has a transaction fee. Assuming 1% here.
        _feeAmount = enteredAmount * 0.01; 
        _totalAmount = enteredAmount + _feeAmount;
        _hasError = false;
      });
    } else {
       setState(() {
        _feeAmount = 0.0;
        _totalAmount = 0.0;
      });
    }
  }

  // Main action button logic
  void _onTransferPressed() {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final amountText = _amountController.text.trim();

    // Validation
    if (phone.length != 10 || _fetchedContactName == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit Ethiopian number')),
      );
      return;
    }

    if (amountText.isEmpty || double.parse(amountText) <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Start Loading (Telebirr Style)
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay (2 seconds)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog();
      }
    });
  }

  // --- UI Components ---

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap OK
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
            Text("Amount Sent: ${double.parse(_amountController.text).toStringAsFixed(2)} ETB"),
            Text("Fee Charged: ${_feeAmount.toStringAsFixed(2)} ETB"),
            const Divider(),
            Text("Total Paid: ${_totalAmount.toStringAsFixed(2)} ETB", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to home screen
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF00796B))),
          ),
        ],
      ),
    );
  }

  // Input decoration styled like Telebirr
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
            backgroundColor: const Color(0xFF00796B), // Telebirr Teal
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

                  // --- Phone Number Input ---
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

                  // --- Dynamic Name Display ---
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

                  // --- Amount Input ---
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))], // Allow decimals
                    decoration: _telebirrInputDecoration(
                      label: 'Amount (ETB)',
                      icon: Icons.money,
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // --- Calculation Summary Box ---
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
                              Text("${double.tryParse(_amountController.text)??0.0} ETB", style: const TextStyle(fontWeight: FontWeight.w500)),
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

                  // --- Transfer Button ---
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- Telebirr Style Fullscreen Loading Overlay ---
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B))),
                    SizedBox(height: 20),
                    Text("Processing...", style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
