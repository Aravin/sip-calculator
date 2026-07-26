import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sip_calculator/main.dart';
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
import 'package:share_plus/share_plus.dart';

class CustomAppDrawer extends StatefulWidget {
  const CustomAppDrawer({super.key});

  @override
  State<CustomAppDrawer> createState() => _CustomAppDrawerState();
}

class _CustomAppDrawerState extends State<CustomAppDrawer> {
  void _shareApp() {
    Share.share('https://play.google.com/store/apps/details?id=io.epix.sip',
        subject: 'Financial Calculator - Investment & Tax Planning Tool');
  }

  void _navigate(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = MyApp.of(context);
    if (themeMode == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Financial Calculator',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All-in-One Finance Planner',
                  style: TextStyle(
                    color:
                        colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _item(Icons.trending_up, 'SIP Calculator',
              'Systematic Investment Plan', () => _navigate(const SIPScreen())),
          _item(
              Icons.monetization_on,
              'Lumpsum Calculator',
              'One-Time Investment Plan',
              () => _navigate(const LumpSumScreen())),
          _item(Icons.arrow_downward, 'SWP Calculator',
              'Systematic Withdraw Plan', () => _navigate(const SWPScreen())),
          _item(Icons.swap_horiz, 'STP Calculator', 'Systematic Transfer Plan',
              () => _navigate(const STPScreen())),
          _item(Icons.savings, 'PPF Calculator', 'Public Provident Fund',
              () => _navigate(const PPFScreen())),
          _item(Icons.home, 'EMI Calculator', 'Loan EMI & Amortization',
              () => _navigate(const EMIScreen())),
          _item(Icons.account_balance, 'FD Calculator', 'Fixed Deposit',
              () => _navigate(const FDScreen())),
          _item(Icons.repeat, 'RD Calculator', 'Recurring Deposit',
              () => _navigate(const RDScreen())),
          _item(
              Icons.bubble_chart,
              'Compound Interest',
              'Compound Interest Calculator',
              () => _navigate(const CompoundInterestScreen())),
          _item(
              Icons.compare_arrows,
              'SIP vs Lumpsum',
              'Compare Investment Strategies',
              () => _navigate(const SipVsLumpsumScreen())),
          _item(Icons.flag, 'Goal Planner', 'Track Financial Goals',
              () => _navigate(const GoalPlannerScreen())),
          _item(Icons.receipt_long, 'Tax Calculator', 'Old vs New Regime',
              () => _navigate(const TaxCalculatorScreen())),
          _item(Icons.merge, 'SIP + Lumpsum', 'Combined Investment Planner',
              () => _navigate(const CombinedScreen())),
          _item(Icons.bookmark, 'Saved Plans', 'Bookmarked Calculations',
              () => _navigate(const SavingsScreen())),
          const Divider(),
          ListTile(
            leading: Icon(Icons.dark_mode, color: colorScheme.primary),
            title: const Text('Toggle Theme'),
            subtitle:
                const Text('Switch Dark/Light', style: TextStyle(fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              themeMode.toggleTheme();
            },
          ),
          ListTile(
            leading: Icon(Icons.share, color: colorScheme.primary),
            title: const Text('Share App'),
            subtitle:
                const Text('Tell your friends', style: TextStyle(fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              _shareApp();
            },
          ),
          ListTile(
            leading: Icon(Icons.star_rate, color: colorScheme.primary),
            title: const Text('Rate the App'),
            subtitle:
                const Text('Leave a review', style: TextStyle(fontSize: 12)),
            onTap: () async {
              Navigator.pop(context);
              await InAppReview.instance.openStoreListing();
            },
          ),
        ],
      ),
    );
  }

  Widget _item(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
