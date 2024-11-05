import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isLoading = true;
  double _totalMonthlyCommitment = 0;
  double _totalCreditUsage = 0;
  int _totalLoansCount = 0;
  int _totalCreditsCount = 0;
  Map<String, double> _loanTypeDistribution = {};
  Map<String, double> _creditLabelDistribution = {};

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      setState(() => _isLoading = true);
      
      final db = DatabaseHelper.instance;
      final loans = await db.getAllLoans();
      final credits = await db.getAllCredits();
      final monthlyCommitment = await db.getTotalMonthlyCommitment();
      final creditUsage = await db.getTotalCreditCardUsage();

      // Calculate loan type distribution
      final loanTypes = <String, double>{};
      for (var loan in loans) {
        final type = loan['type'] as String;
        loanTypes[type] = (loanTypes[type] ?? 0) + (loan['total_amount'] as double);
      }

      // Calculate credit label distribution
      final creditLabels = <String, double>{};
      for (var credit in credits) {
        final label = credit['label'] as String;
        creditLabels[label] = (creditLabels[label] ?? 0) + (credit['amount'] as double);
      }

      setState(() {
        _totalMonthlyCommitment = monthlyCommitment;
        _totalCreditUsage = creditUsage;
        _totalLoansCount = loans.length;
        _totalCreditsCount = credits.length;
        _loanTypeDistribution = loanTypes;
        _creditLabelDistribution = creditLabels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(),
                  const SizedBox(height: 20),
                  _buildLoanAnalysisCard(),
                  const SizedBox(height: 20),
                  _buildCreditAnalysisCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildOverviewItem(
              'Total Monthly Commitment',
              'RM ${_totalMonthlyCommitment.toStringAsFixed(2)}',
              Icons.calendar_today,
            ),
            _buildOverviewItem(
              'Total Credit Usage',
              'RM ${_totalCreditUsage.toStringAsFixed(2)}',
              Icons.credit_card,
            ),
            _buildOverviewItem(
              'Active Loans',
              _totalLoansCount.toString(),
              Icons.account_balance,
            ),
            _buildOverviewItem(
              'Credit Entries',
              _totalCreditsCount.toString(),
              Icons.receipt_long,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanAnalysisCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ..._loanTypeDistribution.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text('\$${entry.value.toStringAsFixed(2)}'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditAnalysisCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credit Distribution by Label',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ..._creditLabelDistribution.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text('\$${entry.value.toStringAsFixed(2)}'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
