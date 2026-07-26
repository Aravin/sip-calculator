import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/combined_screen.dart';
import 'package:sip_calculator/screens/compound_interest_screen.dart';
import 'package:sip_calculator/screens/emi_screen.dart';
import 'package:sip_calculator/screens/fd_screen.dart';
import 'package:sip_calculator/screens/goal_planner_screen.dart';
import 'package:sip_calculator/screens/lumpsum.dart';
import 'package:sip_calculator/screens/ppf.dart';
import 'package:sip_calculator/screens/rd_screen.dart';
import 'package:sip_calculator/screens/savings_screen.dart';
import 'package:sip_calculator/screens/sip.dart';
import 'package:sip_calculator/screens/sip_vs_lumpsum_screen.dart';
import 'package:sip_calculator/screens/stp.dart';
import 'package:sip_calculator/screens/swp.dart';
import 'package:sip_calculator/screens/tax_calculator_screen.dart';
import 'package:sip_calculator/shared/constants.dart';
import 'package:sip_calculator/shared/drawer.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomAppDrawer(),
      body: ListView(
        padding: kAppPadding,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              _card(context, 'SIP', 'Systematic\nInvestment Plan', Icons.trending_up, colorScheme.primary, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SIPScreen()));
              }),
              _card(context, 'Lumpsum', 'One-Time\nInvestment', Icons.monetization_on, colorScheme.tertiary, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LumpSumScreen()));
              }),
              _card(context, 'SWP', 'Systematic\nWithdraw Plan', Icons.arrow_downward, colorScheme.error, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SWPScreen()));
              }),
              _card(context, 'STP', 'Systematic\nTransfer Plan', Icons.swap_horiz, colorScheme.secondary, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const STPScreen()));
              }),
              _card(context, 'PPF', 'Public\nProvident Fund', Icons.savings, const Color(0xFF2E7D32), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PPFScreen()));
              }),
              _card(context, 'EMI', 'Loan EMI &\nAmortization', Icons.home, const Color(0xFFC62828), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EMIScreen()));
              }),
              _card(context, 'FD', 'Fixed\nDeposit', Icons.account_balance, const Color(0xFF1565C0), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FDScreen()));
              }),
              _card(context, 'RD', 'Recurring\nDeposit', Icons.repeat, const Color(0xFF6A1B9A), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RDScreen()));
              }),
              _card(context, 'Compound', 'Compound\nInterest', Icons.bubble_chart, const Color(0xFF00838F), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CompoundInterestScreen()));
              }),
              _card(context, 'Goal Planner', 'Financial\nGoals', Icons.flag, const Color(0xFFE65100), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalPlannerScreen()));
              }),
              _card(context, 'SIP vs Lumpsum', 'Compare\nStrategies', Icons.compare_arrows, colorScheme.primary, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SipVsLumpsumScreen()));
              }),
              _card(context, 'Tax', 'Old vs New\nRegime', Icons.receipt_long, const Color(0xFF37474F), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxCalculatorScreen()));
              }),
              _card(context, 'SIP+Lumpsum', 'Combined Planner', Icons.merge, colorScheme.primary, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CombinedScreen()));
              }),
              _card(context, 'Saved Plans', 'Bookmarked Calcs', Icons.bookmark, const Color(0xFFF9A825), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()));
              }),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, String subtitle, IconData icon, Color iconColor, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
