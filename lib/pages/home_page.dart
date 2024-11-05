import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/section_header.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_action_button.dart';
import 'loans/loan_page.dart';
import 'credits/credit_card_page.dart';
import 'report_page.dart';
import '../database/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _monthlyCommitment = 0.0;
  double _creditCardUsage = 0.0;

  final _currencyFormat = NumberFormat.currency(
    locale: 'ms_MY',
    symbol: 'RM ',
    decimalDigits: 2,
  );

  Future<void> _loadMonthlyCommitment() async {
    final total = await DatabaseHelper.instance.getTotalMonthlyCommitment();
    setState(() {
      _monthlyCommitment = total;
    });
  }

  Future<void> _loadCreditCardUsage() async {
    final usage1 = await DatabaseHelper.instance.getTotalCreditCardUsage();
    setState(() {
      _creditCardUsage = usage1;
    }); 
  }

  @override
  void initState() {
    super.initState();
    _loadMonthlyCommitment();
    _loadCreditCardUsage();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Scaffold(
        // backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, size),
                  SizedBox(height: size.height * 0.02),

                  // Monthly Commitment Section
                  const SectionHeader(title: 'Monthly Commitment', icon: Icons.calendar_today),
                  SizedBox(height: size.height * 0.01),
                  SummaryCard(
                    title: 'Monthly Commitment',
                    amount: _currencyFormat.format(_monthlyCommitment),
                    icon: Icons.calendar_month,
                  ),
                  
                  SizedBox(height: size.height * 0.02),

                  // Credit Card Section  
                  const SectionHeader(title: 'Credit Card', icon: Icons.credit_card),
                  SizedBox(height: size.height * 0.01),
                  SummaryCard(
                    title: 'Current Usage',
                    amount: _currencyFormat.format(_creditCardUsage),
                    icon: Icons.credit_card,
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Quick Actions Section
                  const SectionHeader(title: 'Quick Actions', icon: Icons.flash_on),
                  SizedBox(height: size.height * 0.01),
                  _buildQuickActions(context, size),

                  SizedBox(height: size.height * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: size.width * 0.08,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: size.width * 0.03),
          Text(
            'Money Tracker',
            style: TextStyle(
              fontSize: size.width * 0.07,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Size size) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          QuickActionButton(
            label: 'Loan',
            icon: Icons.account_balance,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoanPage()),
            ).then((_) {
              _loadMonthlyCommitment();
              _loadCreditCardUsage();
            }),
          ),
          SizedBox(width: size.width * 0.03),
          QuickActionButton(
            label: 'Credit Card',
            icon: Icons.credit_card,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreditCardPage()),
            ).then((_) {
              _loadMonthlyCommitment();
              _loadCreditCardUsage();
            }),
          ),
          SizedBox(width: size.width * 0.03),
          QuickActionButton(
            label: 'Report',
            icon: Icons.description,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportPage()),
            ),
          ),
        ],
      ),
    );
  }
} 