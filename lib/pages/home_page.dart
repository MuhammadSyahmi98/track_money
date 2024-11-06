import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/section_header.dart';
// import '../widgets/summary_card.dart';
import '../widgets/quick_action_button.dart';
import 'loans/loan_page.dart';
import 'credits/credit_card_page.dart';
import 'report_page.dart';
import '../database/database_helper.dart';
import 'expenses/expense_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _monthlyCommitment = 0.0;
  double _creditCardUsage = 0.0;
  double _totalExpenses = 0.0;

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

  Future<void> _loadTotalExpenses() async {
    final total = await DatabaseHelper.instance.getTotalExpenses();
    setState(() {
      _totalExpenses = total;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMonthlyCommitment();
    _loadCreditCardUsage();
    _loadTotalExpenses();
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

                  // Summary Section
                  const SectionHeader(title: 'Summary', icon: Icons.analytics),
                  SizedBox(height: size.height * 0.01),
                  _buildSummaryGrid(context, size),

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

  Widget _buildSummaryGrid(BuildContext context, Size size) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of columns based on screen width
        final isWideScreen = constraints.maxWidth > 600;
        final columnCount = isWideScreen ? 3 : 2;
        
        return GridView.count(
          crossAxisCount: columnCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: size.width * 0.02,
          mainAxisSpacing: size.width * 0.02,
          childAspectRatio: isWideScreen ? 1.5 : 1.2,
          children: [
            _buildSummaryItem(
              'Monthly\nCommitment',
              _monthlyCommitment,
              Icons.calendar_month,
              Theme.of(context).colorScheme.primary,
            ),
            _buildSummaryItem(
              'Credit Card\nUsage',
              _creditCardUsage,
              Icons.credit_card,
              Theme.of(context).colorScheme.secondary,
            ),
            _buildSummaryItem(
              'Total\nExpenses',
              _totalExpenses,
              Icons.money_off,
              Theme.of(context).colorScheme.tertiary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryItem(String title, double amount, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color), // Slightly reduced icon size
          const SizedBox(height: 6), // Reduced spacing
          Text(
            title,
            style: TextStyle(
              fontSize: 12, // Reduced from 14
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.1, // Tighter line height for multiline text
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 16, // Slightly reduced from 18
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
            label: 'Expenses',
            icon: Icons.receipt_long,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExpensesPage()),
            ).then((_) {
              _loadTotalExpenses();
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