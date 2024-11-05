import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../database/database_helper.dart';
import '../credits/create_credit_page.dart';

class CreateLoanPage extends StatefulWidget {
  const CreateLoanPage({super.key});

  @override
  State<CreateLoanPage> createState() => _CreateLoanPageState();
}

class _CreateLoanPageState extends State<CreateLoanPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _totalController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();
  final _dueDateController = TextEditingController();

  String _formatPrice(String value) {
    if (value.isEmpty) return '';
    
    // Remove any non-digits
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Convert to decimal by moving decimal point 2 places left
    double number = double.parse(digitsOnly) / 100;
    
    // Format with thousand separators and 2 decimal places
    return number.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  double _parseAmount(String value) {
    return double.parse(value.replaceAll(',', ''));
  }

  Future<void> _saveLoan() async {
    try {
      final loan = {
        'type': _typeController.text,
        'total_amount': _parseAmount(_totalController.text),
        'monthly_payment': _parseAmount(_monthlyPaymentController.text),
        'due_date': int.parse(_dueDateController.text),
        'created_at': DateTime.now().toIso8601String(),
      };

      await DatabaseHelper.instance.createLoan(loan);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan created successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error creating loan'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _totalController.dispose();
    _monthlyPaymentController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Loan'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add_card),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => const CreateCreditPage(),
        //         ),
        //       );
        //     },
        //     tooltip: 'Add Credit',
        //   ),
        // ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Loan Type',
                hintText: 'Enter loan type (e.g., Personal Loan)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter loan type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _totalController,
              decoration: const InputDecoration(
                labelText: 'Total Loan Amount',
                hintText: 'Enter total loan amount',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                final formatted = _formatPrice(value);
                if (formatted != value) {
                  _totalController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _monthlyPaymentController,
              decoration: const InputDecoration(
                labelText: 'Monthly Payment',
                hintText: 'Enter monthly payment amount',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                final formatted = _formatPrice(value);
                if (formatted != value) {
                  _monthlyPaymentController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter monthly payment';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<int>(
              value: _dueDateController.text.isEmpty ? null : int.tryParse(_dueDateController.text),
              decoration: const InputDecoration(
                labelText: 'Due Date',
                hintText: 'Select due date',
              ),
              items: List.generate(31, (index) => index + 1).map((day) {
                return DropdownMenuItem<int>(
                  value: day,
                  child: Text(day.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _dueDateController.text = value.toString();
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select due date';
                }
                return null;
              },
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveLoan();
                }
              },
              child: const Text('Create Loan'),
            ),
          ],
        ),
      ),
    );
  }
}